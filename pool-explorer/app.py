"""
Trinity Mining Pool & Block Explorer Web Application
"""
from flask import Flask, render_template, request, jsonify, redirect, url_for, session, flash
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
from werkzeug.security import check_password_hash, generate_password_hash
from datetime import datetime, timedelta
import logging
import sys

from config.config import Config
from models import db, Block, Worker, Share, Payment, PoolStats, Transaction
from rpc_client import TrinityRPC
from pool_server import PoolServer

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/pool.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
app.config.from_object(Config)

# Initialize database
db.init_app(app)

# Initialize login manager
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'admin_login'

# Admin user class
class AdminUser(UserMixin):
    def __init__(self, id):
        self.id = id

@login_manager.user_loader
def load_user(user_id):
    if user_id == 'admin':
        return AdminUser('admin')
    return None

# Initialize RPC client
rpc_client = TrinityRPC(app.config)

# Initialize pool server
pool_server = PoolServer(app.config, app)

# Create tables
with app.app_context():
    db.create_all()

# Start pool server
pool_server.start()

# ============= Public Routes =============

@app.route('/')
def index():
    """Homepage with pool stats"""
    try:
        # Get network info
        info = rpc_client.getinfo()
        mining_info = rpc_client.getmininginfo()
        
        # Get pool stats
        pool_stats = pool_server.get_pool_stats()
        
        # Get recent blocks
        recent_blocks = Block.query.order_by(Block.height.desc()).limit(10).all()
        
        return render_template('index.html',
            network_info=info,
            mining_info=mining_info,
            pool_stats=pool_stats,
            recent_blocks=recent_blocks
        )
    except Exception as e:
        logger.error(f"Error in index: {e}")
        return render_template('index.html',
            network_info={},
            mining_info={},
            pool_stats={},
            recent_blocks=[]
        )

@app.route('/how-to-mine')
def how_to_mine():
    """Mining instructions"""
    return render_template('how_to_mine.html',
        pool_host=request.host.split(':')[0],
        stratum_port=app.config['STRATUM_PORT']
    )

@app.route('/blocks')
def blocks():
    """Block explorer - list blocks"""
    page = request.args.get('page', 1, type=int)
    blocks = Block.query.order_by(Block.height.desc()).paginate(
        page=page, per_page=app.config['BLOCKS_PER_PAGE'], error_out=False
    )
    return render_template('blocks.html', blocks=blocks)

@app.route('/block/<block_hash>')
def block_detail(block_hash):
    """Block details"""
    block = Block.query.filter_by(hash=block_hash).first_or_404()
    
    # Get block details from daemon
    block_info = rpc_client.getblock(block_hash)
    
    return render_template('block_detail.html', block=block, block_info=block_info)

@app.route('/search')
def search():
    """Search for blocks, transactions, or addresses"""
    query = request.args.get('q', '').strip()
    
    if not query:
        return redirect(url_for('index'))
    
    # Try as block height
    if query.isdigit():
        block = Block.query.filter_by(height=int(query)).first()
        if block:
            return redirect(url_for('block_detail', block_hash=block.hash))
    
    # Try as block hash
    if len(query) == 64:
        block = Block.query.filter_by(hash=query).first()
        if block:
            return redirect(url_for('block_detail', block_hash=block.hash))
        
        # Try as transaction
        tx = Transaction.query.filter_by(txid=query).first()
        if tx:
            return redirect(url_for('transaction_detail', txid=query))
    
    # Try as address
    worker = Worker.query.filter_by(address=query).first()
    if worker:
        return redirect(url_for('worker_stats', address=query))
    
    flash('No results found for your search.', 'warning')
    return redirect(url_for('index'))

@app.route('/worker/<address>')
def worker_stats(address):
    """Worker statistics"""
    worker = Worker.query.filter_by(address=address).first_or_404()
    
    # Get recent shares
    recent_shares = Share.query.filter_by(worker_id=worker.id).order_by(
        Share.timestamp.desc()
    ).limit(100).all()
    
    # Get payments
    payments = Payment.query.filter_by(worker_id=worker.id).order_by(
        Payment.timestamp.desc()
    ).all()
    
    # Get blocks found
    blocks_found = Block.query.filter_by(finder=address).order_by(
        Block.height.desc()
    ).all()
    
    return render_template('worker_stats.html',
        worker=worker,
        recent_shares=recent_shares,
        payments=payments,
        blocks_found=blocks_found
    )

@app.route('/api/stats')
def api_stats():
    """API endpoint for pool stats"""
    pool_stats = pool_server.get_pool_stats()
    info = rpc_client.getinfo()
    mining_info = rpc_client.getmininginfo()
    
    return jsonify({
        'pool': pool_stats,
        'network': info or {},
        'mining': mining_info or {}
    })

@app.route('/api/worker/<address>')
def api_worker(address):
    """API endpoint for worker stats"""
    worker = Worker.query.filter_by(address=address).first()
    if not worker:
        return jsonify({'error': 'Worker not found'}), 404
    
    return jsonify(worker.to_dict())

@app.route('/api/getwork', methods=['POST'])
def api_getwork():
    """API endpoint for getwork mining protocol"""
    data = request.get_json()
    worker_address = data.get('address')
    work_data = data.get('data')
    
    if not worker_address:
        return jsonify({'error': 'Address required'}), 400
    
    if work_data:
        # Submit work
        result = pool_server.submit_share(worker_address, work_data)
        return jsonify(result)
    else:
        # Get work
        work = pool_server.get_work(worker_address)
        if work:
            return jsonify(work)
        else:
            return jsonify({'error': 'No work available'}), 503

# ============= Admin Routes =============

@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    """Admin login page"""
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        if username == app.config['ADMIN_USERNAME'] and password == app.config['ADMIN_PASSWORD']:
            user = AdminUser('admin')
            login_user(user)
            return redirect(url_for('admin_dashboard'))
        else:
            flash('Invalid credentials', 'danger')
    
    return render_template('admin_login.html')

@app.route('/admin/logout')
@login_required
def admin_logout():
    """Admin logout"""
    logout_user()
    return redirect(url_for('index'))

@app.route('/admin')
@login_required
def admin_dashboard():
    """Admin dashboard"""
    # Get comprehensive stats
    pool_stats = pool_server.get_pool_stats()
    
    # Get all workers
    workers = Worker.query.order_by(Worker.last_seen.desc()).all()
    
    # Get recent blocks
    recent_blocks = Block.query.order_by(Block.height.desc()).limit(20).all()
    
    # Get pending payments
    pending_payments = Payment.query.filter_by(status='pending').all()
    
    # Get network info
    info = rpc_client.getinfo()
    mining_info = rpc_client.getmininginfo()
    
    return render_template('admin_dashboard.html',
        pool_stats=pool_stats,
        workers=workers,
        recent_blocks=recent_blocks,
        pending_payments=pending_payments,
        network_info=info,
        mining_info=mining_info
    )

@app.route('/admin/settings', methods=['GET', 'POST'])
@login_required
def admin_settings():
    """Admin settings page"""
    if request.method == 'POST':
        # Update settings (in a real app, save to config file or database)
        flash('Settings updated successfully', 'success')
        return redirect(url_for('admin_settings'))
    
    return render_template('admin_settings.html', config=app.config)

@app.route('/admin/workers')
@login_required
def admin_workers():
    """Admin workers management"""
    workers = Worker.query.order_by(Worker.hashrate.desc()).all()
    return render_template('admin_workers.html', workers=workers)

@app.route('/admin/payments')
@login_required
def admin_payments():
    """Admin payments management"""
    payments = Payment.query.order_by(Payment.timestamp.desc()).limit(100).all()
    return render_template('admin_payments.html', payments=payments)

@app.route('/admin/blocks')
@login_required
def admin_blocks():
    """Admin blocks management"""
    blocks = Block.query.order_by(Block.height.desc()).limit(50).all()
    return render_template('admin_blocks.html', blocks=blocks)

# ============= Error Handlers =============

@app.errorhandler(404)
def not_found(e):
    return render_template('404.html'), 404

@app.errorhandler(500)
def server_error(e):
    return render_template('500.html'), 500

# ============= Template Filters =============

@app.template_filter('datetime')
def format_datetime(value):
    """Format datetime for display"""
    if isinstance(value, datetime):
        return value.strftime('%Y-%m-%d %H:%M:%S')
    return value

@app.template_filter('hashrate')
def format_hashrate(value):
    """Format hashrate for display"""
    if value < 1000:
        return f"{value:.2f} H/s"
    elif value < 1000000:
        return f"{value/1000:.2f} KH/s"
    elif value < 1000000000:
        return f"{value/1000000:.2f} MH/s"
    else:
        return f"{value/1000000000:.2f} GH/s"

@app.template_filter('amount')
def format_amount(value):
    """Format coin amount"""
    return f"{value:.8f}"

if __name__ == '__main__':
    app.run(
        host=app.config['WEB_HOST'],
        port=app.config['WEB_PORT'],
        debug=False
    )
