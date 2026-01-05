"""
Trinity Mining Pool & Explorer Configuration
"""
import os

class Config:
    # Flask settings
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'trinity-pool-secret-key-change-in-production'
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or 'sqlite:///pool.db'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Admin credentials (CHANGE THESE!)
    ADMIN_USERNAME = os.environ.get('ADMIN_USERNAME') or 'admin'
    ADMIN_PASSWORD = os.environ.get('ADMIN_PASSWORD') or 'trinity2024!'
    
    # Trinity daemon RPC settings
    RPC_HOST = os.environ.get('RPC_HOST') or '127.0.0.1'
    RPC_PORT = int(os.environ.get('RPC_PORT') or 62620)
    RPC_USER = os.environ.get('RPC_USER') or 'trinityuser'
    RPC_PASSWORD = os.environ.get('RPC_PASSWORD') or 'trinitypass'
    
    # Pool settings
    POOL_ADDRESS = os.environ.get('POOL_ADDRESS') or ''  # Set your pool payout address
    POOL_FEE = float(os.environ.get('POOL_FEE') or 0.01)  # 1% fee
    MIN_DIFFICULTY = float(os.environ.get('MIN_DIFFICULTY') or 0.0001)
    PAYOUT_THRESHOLD = float(os.environ.get('PAYOUT_THRESHOLD') or 0.1)
    
    # Stratum settings
    STRATUM_HOST = os.environ.get('STRATUM_HOST') or '0.0.0.0'
    STRATUM_PORT = int(os.environ.get('STRATUM_PORT') or 3333)
    
    # Web interface settings
    WEB_HOST = os.environ.get('WEB_HOST') or '0.0.0.0'
    WEB_PORT = int(os.environ.get('WEB_PORT') or 8080)
    
    # Block explorer settings
    BLOCKS_PER_PAGE = int(os.environ.get('BLOCKS_PER_PAGE') or 20)
    TXS_PER_PAGE = int(os.environ.get('TXS_PER_PAGE') or 20)
