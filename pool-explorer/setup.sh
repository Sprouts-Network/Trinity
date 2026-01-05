#!/bin/bash
# Trinity Mining Pool & Explorer - Google Cloud VM Setup Script

set -e

echo "=========================================="
echo "Trinity Mining Pool & Explorer Setup"
echo "=========================================="
echo ""

# Update system
echo "[1/8] Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install dependencies
echo "[2/8] Installing dependencies..."
sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    libboost-all-dev \
    libssl-dev \
    libdb++-dev \
    git \
    nginx \
    supervisor

# Create application directory
echo "[3/8] Setting up application directory..."
APP_DIR="/opt/trinity-pool"
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# Copy application files
echo "[4/8] Copying application files..."
cp -r pool-explorer/* $APP_DIR/
cd $APP_DIR

# Create virtual environment
echo "[5/8] Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# Install Python packages
echo "[6/8] Installing Python packages..."
pip install --upgrade pip
pip install -r requirements.txt

# Create logs directory
mkdir -p logs data

# Configure environment
echo "[7/8] Configuring environment..."
cat > .env << EOF
# Trinity Pool Configuration
# IMPORTANT: Change these values for production!

# Admin credentials
ADMIN_USERNAME=admin
ADMIN_PASSWORD=trinity2024!

# Trinity daemon RPC
RPC_HOST=127.0.0.1
RPC_PORT=62620
RPC_USER=trinityuser
RPC_PASSWORD=trinitypass

# Pool settings
POOL_FEE=0.01
PAYOUT_THRESHOLD=0.1
MIN_DIFFICULTY=0.0001

# Server settings
WEB_HOST=0.0.0.0
WEB_PORT=8080
STRATUM_PORT=3333

# Database
DATABASE_URL=sqlite:///data/pool.db

# Security
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_hex(32))')
EOF

echo ""
echo "Configuration file created at $APP_DIR/.env"
echo "Please edit this file to customize your pool settings!"
echo ""

# Create systemd service
echo "[8/8] Creating systemd service..."
sudo tee /etc/systemd/system/trinity-pool.service > /dev/null << EOF
[Unit]
Description=Trinity Mining Pool & Explorer
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$APP_DIR
Environment="PATH=$APP_DIR/venv/bin"
EnvironmentFile=$APP_DIR/.env
ExecStart=$APP_DIR/venv/bin/python app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Configure Nginx (optional)
echo "Configuring Nginx reverse proxy..."
sudo tee /etc/nginx/sites-available/trinity-pool > /dev/null << EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/trinity-pool /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl restart nginx

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Ensure Trinity daemon is running with RPC enabled"
echo "2. Edit $APP_DIR/.env to configure your pool"
echo "3. Start the pool:"
echo "   sudo systemctl enable trinity-pool"
echo "   sudo systemctl start trinity-pool"
echo ""
echo "4. Check status:"
echo "   sudo systemctl status trinity-pool"
echo "   sudo journalctl -u trinity-pool -f"
echo ""
echo "5. Access the web interface:"
echo "   http://YOUR_SERVER_IP"
echo ""
echo "Admin Login:"
echo "   Username: admin"
echo "   Password: trinity2024!"
echo "   (Change these in $APP_DIR/.env)"
echo ""
echo "Firewall ports to open:"
echo "   - 80 (HTTP)"
echo "   - 3333 (Stratum mining)"
echo "   - 62620 (Trinity RPC, if remote)"
echo ""
