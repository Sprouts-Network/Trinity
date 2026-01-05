"""
Database models for Trinity Mining Pool
"""
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class Block(db.Model):
    """Blocks found by the pool"""
    __tablename__ = 'blocks'
    
    id = db.Column(db.Integer, primary_key=True)
    height = db.Column(db.Integer, unique=True, nullable=False, index=True)
    hash = db.Column(db.String(64), unique=True, nullable=False, index=True)
    prev_hash = db.Column(db.String(64), nullable=False)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    difficulty = db.Column(db.Float, nullable=False)
    reward = db.Column(db.Float, nullable=False)
    finder = db.Column(db.String(64), nullable=True)  # Worker address who found it
    confirmations = db.Column(db.Integer, default=0)
    tx_count = db.Column(db.Integer, default=0)
    algo = db.Column(db.String(20), default='sha256d')
    
    def to_dict(self):
        return {
            'height': self.height,
            'hash': self.hash,
            'prev_hash': self.prev_hash,
            'timestamp': self.timestamp.isoformat(),
            'difficulty': self.difficulty,
            'reward': self.reward,
            'finder': self.finder,
            'confirmations': self.confirmations,
            'tx_count': self.tx_count,
            'algo': self.algo
        }

class Worker(db.Model):
    """Mining workers"""
    __tablename__ = 'workers'
    
    id = db.Column(db.Integer, primary_key=True)
    address = db.Column(db.String(64), unique=True, nullable=False, index=True)
    last_seen = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    total_shares = db.Column(db.Integer, default=0)
    valid_shares = db.Column(db.Integer, default=0)
    invalid_shares = db.Column(db.Integer, default=0)
    total_paid = db.Column(db.Float, default=0.0)
    pending_balance = db.Column(db.Float, default=0.0)
    hashrate = db.Column(db.Float, default=0.0)
    difficulty = db.Column(db.Float, default=0.0001)
    
    shares = db.relationship('Share', backref='worker', lazy=True, cascade='all, delete-orphan')
    payments = db.relationship('Payment', backref='worker', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'address': self.address,
            'last_seen': self.last_seen.isoformat(),
            'total_shares': self.total_shares,
            'valid_shares': self.valid_shares,
            'invalid_shares': self.invalid_shares,
            'total_paid': self.total_paid,
            'pending_balance': self.pending_balance,
            'hashrate': self.hashrate,
            'difficulty': self.difficulty
        }

class Share(db.Model):
    """Mining shares submitted by workers"""
    __tablename__ = 'shares'
    
    id = db.Column(db.Integer, primary_key=True)
    worker_id = db.Column(db.Integer, db.ForeignKey('workers.id'), nullable=False, index=True)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, index=True)
    difficulty = db.Column(db.Float, nullable=False)
    valid = db.Column(db.Boolean, default=True)
    block_height = db.Column(db.Integer, nullable=True)
    
class Payment(db.Model):
    """Payments made to workers"""
    __tablename__ = 'payments'
    
    id = db.Column(db.Integer, primary_key=True)
    worker_id = db.Column(db.Integer, db.ForeignKey('workers.id'), nullable=False, index=True)
    amount = db.Column(db.Float, nullable=False)
    block_height = db.Column(db.Integer, nullable=False, index=True)
    txid = db.Column(db.String(64), nullable=True)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    status = db.Column(db.String(20), default='pending')  # pending, confirmed, failed
    
    def to_dict(self):
        return {
            'amount': self.amount,
            'block_height': self.block_height,
            'txid': self.txid,
            'timestamp': self.timestamp.isoformat(),
            'status': self.status
        }

class PoolStats(db.Model):
    """Pool statistics snapshots"""
    __tablename__ = 'pool_stats'
    
    id = db.Column(db.Integer, primary_key=True)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, index=True)
    hashrate = db.Column(db.Float, default=0.0)
    workers = db.Column(db.Integer, default=0)
    blocks_found = db.Column(db.Integer, default=0)
    total_paid = db.Column(db.Float, default=0.0)
    
class Transaction(db.Model):
    """Blockchain transactions for explorer"""
    __tablename__ = 'transactions'
    
    id = db.Column(db.Integer, primary_key=True)
    txid = db.Column(db.String(64), unique=True, nullable=False, index=True)
    block_height = db.Column(db.Integer, nullable=True, index=True)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    confirmations = db.Column(db.Integer, default=0)
    
    def to_dict(self):
        return {
            'txid': self.txid,
            'block_height': self.block_height,
            'timestamp': self.timestamp.isoformat(),
            'confirmations': self.confirmations
        }
