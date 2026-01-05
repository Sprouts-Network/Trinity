#!/bin/bash
# Local Development Test Script for Trinity Pool

set -e

echo "=========================================="
echo "Trinity Pool - Local Development Setup"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "requirements.txt" ]; then
    echo "Error: Must run from pool-explorer directory"
    exit 1
fi

# Check Python version
python3 --version

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "[1/4] Creating virtual environment..."
    python3 -m venv venv
else
    echo "[1/4] Virtual environment already exists"
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "[2/4] Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Create necessary directories
echo "[3/4] Creating directories..."
mkdir -p logs data static/css static/js static/images config

# Create test configuration
if [ ! -f ".env" ]; then
    echo "[4/4] Creating test configuration..."
    cat > .env << EOF
# Trinity Pool - Test Configuration
# WARNING: For development only!

# Admin credentials
ADMIN_USERNAME=admin
ADMIN_PASSWORD=admin123

# Trinity daemon RPC (adjust if needed)
RPC_HOST=127.0.0.1
RPC_PORT=62620
RPC_USER=trinityuser
RPC_PASSWORD=trinitypass

# Pool settings
POOL_FEE=0.01
PAYOUT_THRESHOLD=0.1
MIN_DIFFICULTY=0.0001

# Server settings
WEB_HOST=127.0.0.1
WEB_PORT=5000
STRATUM_PORT=3333

# Database
DATABASE_URL=sqlite:///data/pool_test.db

# Security
SECRET_KEY=test-secret-key-not-for-production
EOF
    echo "Configuration created at .env"
else
    echo "[4/4] Configuration file already exists"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "To start the pool for testing:"
echo "  source venv/bin/activate"
echo "  python app.py"
echo ""
echo "Then access:"
echo "  Web interface: http://127.0.0.1:5000"
echo "  Admin panel: http://127.0.0.1:5000/admin/login"
echo "    Username: admin"
echo "    Password: admin123"
echo ""
echo "IMPORTANT:"
echo "  - Make sure Trinity daemon is running with RPC enabled"
echo "  - Update RPC credentials in .env if needed"
echo "  - This is for TESTING ONLY, not production!"
echo ""
