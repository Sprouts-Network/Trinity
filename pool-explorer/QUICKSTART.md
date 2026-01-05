# Trinity Mining Pool & Explorer - Quick Start Guide

## For Pool Administrators

### Prerequisites
- Ubuntu 20.04+ server (Google Cloud VM or similar)
- Trinity wallet daemon (trinityd) compiled and installed
- Basic Linux command line knowledge

### 5-Minute Setup

1. **Start Trinity Daemon**
   ```bash
   # First, configure trinity
   mkdir -p ~/.trinity
   cat > ~/.trinity/trinity.conf << EOF
   server=1
   rpcuser=trinityuser
   rpcpassword=$(openssl rand -hex 16)
   rpcallowip=127.0.0.1
   rpcport=62620
   EOF
   
   # Start the daemon
   ./trinityd -daemon
   
   # Wait for sync (check with)
   ./trinity-cli getinfo
   ```

2. **Deploy Pool**
   ```bash
   cd pool-explorer
   ./setup.sh
   ```

3. **Configure Pool**
   ```bash
   nano /opt/trinity-pool/.env
   # Change ADMIN_PASSWORD
   # Update RPC_PASSWORD to match trinity.conf
   ```

4. **Start Pool**
   ```bash
   sudo systemctl start trinity-pool
   sudo systemctl enable trinity-pool
   ```

5. **Access Web Interface**
   - Open browser: `http://YOUR_SERVER_IP`
   - Admin panel: `http://YOUR_SERVER_IP/admin/login`

### Important Security Steps

1. Change admin credentials in `/opt/trinity-pool/.env`
2. Update RPC password to match Trinity daemon
3. Configure firewall (only ports 80, 3333)
4. Set up HTTPS with Let's Encrypt (optional but recommended)

## For Miners

### How to Connect

1. **Get Your Wallet Address**
   - Open Trinity wallet
   - Go to Receive tab
   - Copy your address

2. **Download Mining Software**
   - CPUMiner for CPU mining
   - CGMiner for GPU mining

3. **Start Mining**
   ```bash
   # CPU Mining (SHA256D)
   minerd -a sha256d -o http://POOL_IP:3333 -u YOUR_WALLET_ADDRESS -p x
   
   # GPU Mining
   cgminer -o http://POOL_IP:3333 -u YOUR_WALLET_ADDRESS -p x --algo sha256d
   ```

4. **Check Your Stats**
   - Go to pool website
   - Search for your wallet address
   - View hashrate and earnings

### Supported Algorithms
- SHA256D (default)
- Scrypt (configure in miner)
- Groestl (configure in miner)

## Troubleshooting

### Pool Won't Start
```bash
# Check logs
sudo journalctl -u trinity-pool -f

# Verify Trinity is running
./trinity-cli getinfo

# Test RPC connection
curl -u trinityuser:PASSWORD --data-binary '{"jsonrpc":"1.0","id":"test","method":"getinfo","params":[]}' -H 'content-type: text/plain;' http://127.0.0.1:62620/
```

### Can't Login to Admin Panel
- Default username: `admin`
- Default password: `trinity2024!`
- Change in `/opt/trinity-pool/.env`

### Miners Can't Connect
- Check port 3333 is open: `sudo ufw allow 3333/tcp`
- Verify pool is running: `sudo systemctl status trinity-pool`
- Check server IP is correct

### No Payments Received
- Ensure pending balance > minimum threshold (default 0.1 TRIN)
- Pool must find blocks to make payments
- Check "Worker Stats" page for pending balance

## Configuration Reference

### Pool Settings (`/opt/trinity-pool/.env`)

```bash
# Admin access
ADMIN_USERNAME=admin
ADMIN_PASSWORD=your_secure_password

# Trinity daemon connection
RPC_HOST=127.0.0.1
RPC_PORT=62620
RPC_USER=trinityuser
RPC_PASSWORD=your_rpc_password

# Pool configuration
POOL_FEE=0.01              # 1% pool fee
PAYOUT_THRESHOLD=0.1       # Min payout: 0.1 TRIN
MIN_DIFFICULTY=0.0001      # Starting difficulty

# Ports
WEB_PORT=8080              # Web interface
STRATUM_PORT=3333          # Mining port
```

### Trinity Daemon (`~/.trinity/trinity.conf`)

```bash
server=1
rpcuser=trinityuser
rpcpassword=your_rpc_password
rpcallowip=127.0.0.1
rpcport=62620

# Optional: enable built-in mining
gen=0
genproclimit=1
```

## Google Cloud VM Setup

### Create VM
```bash
gcloud compute instances create trinity-pool \
  --machine-type=e2-medium \
  --zone=us-central1-a \
  --image-family=ubuntu-2004-lts \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=20GB \
  --tags=http-server,mining-pool
```

### Configure Firewall
```bash
gcloud compute firewall-rules create allow-mining \
  --allow=tcp:3333 \
  --target-tags=mining-pool \
  --description="Allow Trinity mining connections"

gcloud compute firewall-rules create allow-http \
  --allow=tcp:80 \
  --target-tags=http-server \
  --description="Allow HTTP traffic"
```

### Connect to VM
```bash
gcloud compute ssh trinity-pool --zone=us-central1-a
```

Then follow the 5-minute setup above.

## Advanced Configuration

### Use PostgreSQL Instead of SQLite

1. Install PostgreSQL:
   ```bash
   sudo apt-get install postgresql postgresql-contrib libpq-dev
   ```

2. Create database:
   ```bash
   sudo -u postgres createuser trinity
   sudo -u postgres createdb trinity_pool
   sudo -u postgres psql -c "ALTER USER trinity WITH PASSWORD 'password';"
   ```

3. Update `.env`:
   ```bash
   DATABASE_URL=postgresql://trinity:password@localhost/trinity_pool
   ```

### Enable HTTPS

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Increase Performance

1. Use PostgreSQL instead of SQLite
2. Increase worker processes in systemd service
3. Use Redis for session storage
4. Enable nginx caching

## Monitoring

### View Logs
```bash
# Pool application logs
tail -f /opt/trinity-pool/logs/pool.log

# System service logs
sudo journalctl -u trinity-pool -f

# Nginx logs
tail -f /var/log/nginx/access.log
```

### Check Status
```bash
# Pool service
sudo systemctl status trinity-pool

# Trinity daemon
./trinity-cli getinfo
./trinity-cli getmininginfo

# Database size
du -sh /opt/trinity-pool/data/pool.db
```

## Support

- Issues: https://github.com/Sprouts-Network/Trinity/issues
- Documentation: See README.md in pool-explorer directory

## License

MIT License - See COPYING file
