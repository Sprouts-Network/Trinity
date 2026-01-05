"""
Simple mining pool server using getwork protocol
Supports basic pool mining with share validation
"""
import socket
import json
import logging
import threading
import time
from datetime import datetime, timedelta
from models import db, Worker, Share, Block, Payment
from rpc_client import TrinityRPC

logger = logging.getLogger(__name__)

class PoolServer:
    """Mining pool server"""
    
    def __init__(self, config, app):
        self.config = config
        self.app = app
        self.rpc = TrinityRPC(config)
        self.running = False
        self.current_work = None
        self.workers = {}
        self.shares_window = {}  # Track shares in time window for hashrate calc
        
    def start(self):
        """Start the pool server"""
        self.running = True
        
        # Start work update thread
        work_thread = threading.Thread(target=self._update_work_loop, daemon=True)
        work_thread.start()
        
        # Start share processing thread
        share_thread = threading.Thread(target=self._process_shares_loop, daemon=True)
        share_thread.start()
        
        # Start payment thread
        payment_thread = threading.Thread(target=self._payment_loop, daemon=True)
        payment_thread.start()
        
        logger.info("Pool server started")
    
    def stop(self):
        """Stop the pool server"""
        self.running = False
        logger.info("Pool server stopped")
    
    def _update_work_loop(self):
        """Update work template periodically"""
        while self.running:
            try:
                work = self.rpc.getwork()
                if work:
                    self.current_work = work
                    logger.debug("Updated work template")
            except Exception as e:
                logger.error(f"Error updating work: {e}")
            time.sleep(10)  # Update every 10 seconds
    
    def get_work(self, worker_address):
        """Get work for a worker"""
        with self.app.app_context():
            # Get or create worker
            worker = Worker.query.filter_by(address=worker_address).first()
            if not worker:
                # Validate address
                addr_info = self.rpc.validateaddress(worker_address)
                if not addr_info or not addr_info.get('isvalid'):
                    return None
                
                worker = Worker(address=worker_address)
                db.session.add(worker)
                db.session.commit()
            
            # Update last seen
            worker.last_seen = datetime.utcnow()
            db.session.commit()
            
            # Return current work
            if self.current_work:
                return self.current_work.copy()
            
            return None
    
    def submit_share(self, worker_address, data):
        """Submit a share from a worker"""
        with self.app.app_context():
            worker = Worker.query.filter_by(address=worker_address).first()
            if not worker:
                return {'error': 'Unknown worker'}
            
            try:
                # Validate the share by submitting to daemon
                result = self.rpc.getwork([data])
                
                if result is True:
                    # Valid block found!
                    logger.info(f"Block found by {worker_address}!")
                    self._handle_block_found(worker, data)
                    valid = True
                elif result is False:
                    # Valid share but not a block
                    valid = True
                else:
                    # Invalid share
                    valid = False
                
                # Record share
                share = Share(
                    worker_id=worker.id,
                    difficulty=worker.difficulty,
                    valid=valid
                )
                db.session.add(share)
                
                # Update worker stats
                worker.total_shares += 1
                if valid:
                    worker.valid_shares += 1
                else:
                    worker.invalid_shares += 1
                
                worker.last_seen = datetime.utcnow()
                db.session.commit()
                
                # Track for hashrate calculation
                if worker_address not in self.shares_window:
                    self.shares_window[worker_address] = []
                self.shares_window[worker_address].append({
                    'time': datetime.utcnow(),
                    'difficulty': worker.difficulty
                })
                
                return {'result': valid}
                
            except Exception as e:
                logger.error(f"Error processing share: {e}")
                return {'error': str(e)}
    
    def _handle_block_found(self, worker, data):
        """Handle a block found by the pool"""
        try:
            # Get block info
            block_count = self.rpc.getblockcount()
            if block_count:
                block_hash = self.rpc.getblockhash(block_count)
                block_info = self.rpc.getblock(block_hash)
                
                if block_info:
                    # Record block
                    block = Block(
                        height=block_info.get('height'),
                        hash=block_info.get('hash'),
                        prev_hash=block_info.get('previousblockhash', ''),
                        difficulty=block_info.get('difficulty', 0),
                        reward=50.0,  # Default, adjust based on your coin
                        finder=worker.address,
                        tx_count=len(block_info.get('tx', [])),
                        algo='sha256d'
                    )
                    db.session.add(block)
                    db.session.commit()
                    
                    # Trigger payments for this block
                    self._process_block_payments(block)
                    
        except Exception as e:
            logger.error(f"Error handling block found: {e}")
    
    def _process_shares_loop(self):
        """Process shares and update hashrates"""
        while self.running:
            try:
                with self.app.app_context():
                    # Calculate hashrates for all workers
                    cutoff = datetime.utcnow() - timedelta(minutes=10)
                    
                    for worker_addr in list(self.shares_window.keys()):
                        # Remove old shares
                        shares = self.shares_window[worker_addr]
                        shares = [s for s in shares if s['time'] > cutoff]
                        self.shares_window[worker_addr] = shares
                        
                        # Calculate hashrate
                        if shares:
                            total_difficulty = sum(s['difficulty'] for s in shares)
                            time_span = (datetime.utcnow() - shares[0]['time']).total_seconds()
                            if time_span > 0:
                                hashrate = (total_difficulty * (2**32)) / time_span
                                
                                # Update worker
                                worker = Worker.query.filter_by(address=worker_addr).first()
                                if worker:
                                    worker.hashrate = hashrate
                                    db.session.commit()
                
            except Exception as e:
                logger.error(f"Error processing shares: {e}")
            
            time.sleep(60)  # Update every minute
    
    def _process_block_payments(self, block):
        """Process payments for a found block"""
        try:
            # Get all shares for this round (since last block)
            last_block = Block.query.filter(Block.height < block.height).order_by(Block.height.desc()).first()
            if last_block:
                cutoff = last_block.timestamp
            else:
                cutoff = datetime.utcnow() - timedelta(hours=24)
            
            # Get all valid shares since cutoff
            shares = Share.query.filter(Share.timestamp >= cutoff, Share.valid == True).all()
            
            # Calculate share distribution
            total_difficulty = sum(s.difficulty for s in shares)
            if total_difficulty == 0:
                return
            
            # Group by worker
            worker_shares = {}
            for share in shares:
                if share.worker_id not in worker_shares:
                    worker_shares[share.worker_id] = 0
                worker_shares[share.worker_id] += share.difficulty
            
            # Calculate payments (reward minus pool fee)
            net_reward = block.reward * (1 - self.config.POOL_FEE)
            
            for worker_id, difficulty in worker_shares.items():
                worker = Worker.query.get(worker_id)
                if worker:
                    amount = net_reward * (difficulty / total_difficulty)
                    
                    # Add to pending balance
                    worker.pending_balance += amount
                    
                    # Record payment
                    payment = Payment(
                        worker_id=worker_id,
                        amount=amount,
                        block_height=block.height,
                        status='pending'
                    )
                    db.session.add(payment)
            
            db.session.commit()
            logger.info(f"Processed payments for block {block.height}")
            
        except Exception as e:
            logger.error(f"Error processing block payments: {e}")
            db.session.rollback()
    
    def _payment_loop(self):
        """Process pending payments periodically"""
        while self.running:
            try:
                with self.app.app_context():
                    # Find workers with pending balance above threshold
                    workers = Worker.query.filter(
                        Worker.pending_balance >= self.config.PAYOUT_THRESHOLD
                    ).all()
                    
                    if workers:
                        # Prepare payment batch
                        amounts = {}
                        for worker in workers:
                            amounts[worker.address] = float(worker.pending_balance)
                        
                        # Send payments
                        try:
                            txid = self.rpc.sendmany("", amounts)
                            if txid:
                                # Update workers and payments
                                for worker in workers:
                                    worker.total_paid += worker.pending_balance
                                    worker.pending_balance = 0.0
                                    
                                    # Update pending payments
                                    pending = Payment.query.filter_by(
                                        worker_id=worker.id,
                                        status='pending'
                                    ).all()
                                    for payment in pending:
                                        payment.status = 'confirmed'
                                        payment.txid = txid
                                
                                db.session.commit()
                                logger.info(f"Processed payments in tx {txid}")
                        except Exception as e:
                            logger.error(f"Error sending payments: {e}")
                
            except Exception as e:
                logger.error(f"Error in payment loop: {e}")
            
            time.sleep(300)  # Check every 5 minutes
    
    def get_pool_stats(self):
        """Get current pool statistics"""
        with self.app.app_context():
            total_workers = Worker.query.count()
            active_workers = Worker.query.filter(
                Worker.last_seen >= datetime.utcnow() - timedelta(minutes=10)
            ).count()
            total_hashrate = db.session.query(
                db.func.sum(Worker.hashrate)
            ).scalar() or 0
            blocks_found = Block.query.count()
            total_paid = db.session.query(
                db.func.sum(Worker.total_paid)
            ).scalar() or 0
            
            return {
                'total_workers': total_workers,
                'active_workers': active_workers,
                'total_hashrate': total_hashrate,
                'blocks_found': blocks_found,
                'total_paid': total_paid
            }
