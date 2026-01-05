# Trinity Mining Pool & Block Explorer Deployment Guide

This guide will help you deploy the Trinity Mining Pool and Block Explorer on a Google Cloud VM.

## Overview

The Trinity Pool & Explorer provides:

- **Web-based Mining Pool**: Workers connect and mine using their wallet address as username
- **Block Explorer**: Browse blocks, transactions, and search by address
- **Admin Panel**: Full control over pool settings, workers, and payments
- **Automatic Payments**: Proportional rewards distributed every block
- **Real-time Statistics**: Worker hashrates, pool stats, and network info

## Quick Links

- **Pool Explorer Documentation**: [pool-explorer/README.md](pool-explorer/README.md)
- **Quick Start Guide**: [pool-explorer/QUICKSTART.md](pool-explorer/QUICKSTART.md)
- **Setup Script**: [pool-explorer/setup.sh](pool-explorer/setup.sh)

## Prerequisites

1. **Google Cloud VM** (or any Ubuntu 20.04+ server)
   - Recommended: e2-medium (2 vCPU, 4GB RAM)
   - Minimum 20GB storage
   - Static IP address

2. **Trinity Daemon** built and installed
   - Build from source or use pre-built binaries
   - See main README for build instructions

3. **Domain Name** (optional but recommended)
   - For HTTPS/SSL setup
   - Point A record to your server IP

## Installation Steps

### 1. Prepare Your Server

```bash
# Connect to your VM
ssh your-server

# Update system
sudo apt-get update && sudo apt-get upgrade -y
```

### 2. Build Trinity Daemon

If you haven't already built Trinity:

```bash
# Install build dependencies
sudo apt-get install -y build-essential libboost-all-dev libssl-dev libdb++-dev

# Navigate to Trinity source
cd /path/to/Trinity/src

# Build daemon
make -f makefile.unix
```

### 3. Configure Trinity Daemon

```bash
# Create configuration directory
mkdir -p ~/.trinity

# Create configuration file
cat > ~/.trinity/trinity.conf << EOF
server=1
rpcuser=trinityuser
rpcpassword=$(openssl rand -hex 16)
rpcallowip=127.0.0.1
rpcport=62620
daemon=1

# Optional: Enable mining in wallet
gen=0
EOF

# Start the daemon
./trinityd

# Verify it's running
./trinity-cli getinfo
```

### 4. Deploy Mining Pool

```bash
# Navigate to pool directory
cd /path/to/Trinity/pool-explorer

# Run the automated setup script
chmod +x setup.sh
./setup.sh
```

The setup script will:
- Install Python and dependencies
- Create a virtual environment
- Configure systemd service
- Set up Nginx reverse proxy
- Create configuration files

### 5. Configure the Pool

Edit the configuration file:

```bash
sudo nano /opt/trinity-pool/.env
```

**Important settings to change:**

```bash
# Change these immediately!
ADMIN_USERNAME=your_admin_username
ADMIN_PASSWORD=your_secure_password

# Match Trinity daemon RPC credentials
RPC_USER=trinityuser
RPC_PASSWORD=your_rpc_password_from_trinity.conf

# Pool settings (optional)
POOL_FEE=0.01              # 1% pool fee
PAYOUT_THRESHOLD=0.1       # Minimum 0.1 TRIN for payout
```

### 6. Start the Pool

```bash
# Enable and start the service
sudo systemctl enable trinity-pool
sudo systemctl start trinity-pool

# Check status
sudo systemctl status trinity-pool

# View logs
sudo journalctl -u trinity-pool -f
```

### 7. Configure Firewall

```bash
# Allow HTTP traffic
sudo ufw allow 80/tcp

# Allow mining connections
sudo ufw allow 3333/tcp

# Enable firewall
sudo ufw enable
```

For Google Cloud specifically:

```bash
# Create firewall rules
gcloud compute firewall-rules create allow-trinity-pool \
  --allow=tcp:80,tcp:3333 \
  --target-tags=trinity-pool \
  --description="Allow Trinity pool and mining traffic"
```

### 8. Access Your Pool

1. **Public Interface**: `http://YOUR_SERVER_IP`
2. **Admin Panel**: `http://YOUR_SERVER_IP/admin/login`
   - Default username: `admin`
   - Default password: `trinity2024!` (CHANGE THIS!)

## Mining to Your Pool

Once the pool is running, miners can connect:

### CPU Mining (SHA256D)
```bash
minerd -a sha256d -o http://YOUR_SERVER_IP:3333 -u WALLET_ADDRESS -p x
```

### GPU Mining
```bash
cgminer -o http://YOUR_SERVER_IP:3333 -u WALLET_ADDRESS -p x --algo sha256d
```

**Important**: The wallet address IS the worker username. All payments are sent directly to this address.

## Features

### Public Web Interface

- **Homepage**: Real-time pool statistics, recent blocks, network info
- **How to Mine**: Complete instructions for miners
- **Block Explorer**: Browse all blocks with search functionality
- **Worker Stats**: Search by wallet address to view:
  - Current hashrate
  - Share statistics
  - Pending balance
  - Payment history
  - Blocks found

### Admin Panel

Access at `/admin/login`:

- **Dashboard**: Comprehensive overview of pool operations
- **Workers**: Manage and monitor all miners
- **Blocks**: View all blocks found by the pool
- **Payments**: Track all payments and pending balances
- **Settings**: Configure pool parameters

### Payment System

- **Method**: Proportional (PROP)
- **Timing**: Every block found by the pool
- **Distribution**: Based on share difficulty contributed
- **Automatic**: No manual intervention required
- **Minimum Payout**: 0.1 TRIN (configurable)
- **Pool Fee**: 1% (configurable)

## Advanced Configuration

### Enable HTTPS

For production, enable SSL:

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Use PostgreSQL

For better performance:

```bash
# Install PostgreSQL
sudo apt-get install postgresql libpq-dev

# Create database
sudo -u postgres createdb trinity_pool

# Update .env
DATABASE_URL=postgresql://user:pass@localhost/trinity_pool
```

### Monitoring

View real-time logs:

```bash
# Application logs
tail -f /opt/trinity-pool/logs/pool.log

# System service
sudo journalctl -u trinity-pool -f

# Trinity daemon
./trinity-cli getinfo
./trinity-cli getmininginfo
```

## Troubleshooting

### Pool won't start

```bash
# Check Trinity daemon is running
./trinity-cli getinfo

# Verify RPC credentials match
grep rpcpassword ~/.trinity/trinity.conf
grep RPC_PASSWORD /opt/trinity-pool/.env

# Check logs for errors
sudo journalctl -u trinity-pool -n 50
```

### Can't access web interface

```bash
# Verify service is running
sudo systemctl status trinity-pool

# Check if port is open
sudo netstat -tlnp | grep 8080

# Test nginx
sudo nginx -t
sudo systemctl status nginx
```

### Miners can't connect

```bash
# Verify port 3333 is open
sudo ufw status
sudo netstat -tlnp | grep 3333

# Check pool logs
tail -f /opt/trinity-pool/logs/pool.log
```

## Maintenance

### Update Pool Software

```bash
cd /path/to/Trinity
git pull

# Copy new files
sudo cp -r pool-explorer/* /opt/trinity-pool/

# Restart service
sudo systemctl restart trinity-pool
```

### Backup Database

```bash
# For SQLite
sudo cp /opt/trinity-pool/data/pool.db /backup/location/

# For PostgreSQL
sudo -u postgres pg_dump trinity_pool > trinity_pool_backup.sql
```

### View Statistics

```bash
# Check pool status
curl http://localhost:8080/api/stats | jq

# View worker count
sqlite3 /opt/trinity-pool/data/pool.db "SELECT COUNT(*) FROM workers;"

# Check blocks found
sqlite3 /opt/trinity-pool/data/pool.db "SELECT COUNT(*) FROM blocks;"
```

## Security Best Practices

1. **Change default credentials** immediately
2. **Use strong passwords** for admin and RPC
3. **Enable HTTPS** for production use
4. **Regular backups** of database
5. **Monitor logs** for suspicious activity
6. **Keep software updated**
7. **Firewall**: Only open necessary ports
8. **RPC**: Never expose to public internet

## Support

- **Documentation**: See [pool-explorer/README.md](pool-explorer/README.md)
- **Issues**: https://github.com/Sprouts-Network/Trinity/issues
- **Quick Start**: [pool-explorer/QUICKSTART.md](pool-explorer/QUICKSTART.md)

## Architecture

```
┌─────────────────┐
│   Web Browser   │
└────────┬────────┘
         │ HTTP
         ↓
┌─────────────────┐
│  Nginx (Port 80)│
└────────┬────────┘
         │
         ↓
┌─────────────────┐     ┌──────────────────┐
│ Flask Web App   │────→│  Trinity Daemon  │
│  (Port 8080)    │ RPC │   (Port 62620)   │
└────────┬────────┘     └──────────────────┘
         │
         ↓
┌─────────────────┐
│ Pool Server     │
│  (Port 3333)    │←──── Mining clients
└────────┬────────┘      (minerd, cgminer)
         │
         ↓
┌─────────────────┐
│   Database      │
│ (SQLite/Postgres)│
└─────────────────┘
```

## License

MIT License - See [COPYING](COPYING) for details

---

For detailed information, see the complete documentation in the [pool-explorer](pool-explorer/) directory.
