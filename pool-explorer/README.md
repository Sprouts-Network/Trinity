# Trinity Mining Pool & Block Explorer

## Overview

This is a complete mining pool and block explorer solution for Trinity cryptocurrency. It provides:

- **Mining Pool**: Stratum-compatible pool server with automatic payments
- **Block Explorer**: Web-based blockchain explorer with search functionality
- **Worker Management**: Individual worker statistics and monitoring
- **Admin Panel**: Comprehensive administrative interface
- **Payment System**: Automatic proportional payments to workers

## Features

### Public Interface
- Real-time pool statistics and hashrate
- Block explorer with transaction search
- Worker statistics lookup by wallet address
- Mining instructions and setup guide
- Responsive web design

### Admin Panel
- Comprehensive dashboard with pool metrics
- Worker management and monitoring
- Block and payment tracking
- Configuration management
- Detailed statistics and reports

### Mining Pool
- Getwork protocol support
- Automatic difficulty adjustment per worker
- Proportional payment system (PROP)
- Real-time hashrate calculation
- Share validation and tracking
- Automatic block detection

## Requirements

### Server Requirements
- **OS**: Ubuntu 20.04 LTS or newer
- **RAM**: Minimum 2GB (4GB recommended)
- **Storage**: 10GB+ for blockchain data
- **CPU**: 2+ cores recommended
- **Network**: Static IP address, open ports

### Software Requirements
- Python 3.8+
- Trinity daemon (trinityd) with RPC enabled
- PostgreSQL or SQLite
- Nginx (recommended for production)

## Installation

### Quick Setup on Google Cloud VM

1. **Create a VM instance**:
   ```bash
   # Recommended specs:
   # - Machine type: e2-medium (2 vCPU, 4GB RAM)
   # - Boot disk: Ubuntu 20.04 LTS, 20GB
   # - Firewall: Allow HTTP, HTTPS
   ```

2. **Clone the repository**:
   ```bash
   git clone https://github.com/Sprouts-Network/Trinity.git
   cd Trinity
   ```

3. **Run setup script**:
   ```bash
   cd pool-explorer
   chmod +x setup.sh
   ./setup.sh
   ```

4. **Configure Trinity daemon**:
   
   Edit Trinity configuration (`~/.trinity/trinity.conf`):
   ```
   server=1
   rpcuser=trinityuser
   rpcpassword=YOUR_SECURE_PASSWORD
   rpcallowip=127.0.0.1
   rpcport=62620
   
   # Enable mining
   gen=0
   ```

5. **Start Trinity daemon**:
   ```bash
   ./trinityd -daemon
   ```

6. **Configure the pool**:
   
   Edit `/opt/trinity-pool/.env`:
   ```bash
   # Change admin credentials
   ADMIN_USERNAME=your_admin_username
   ADMIN_PASSWORD=your_secure_password
   
   # Set RPC credentials (must match trinity.conf)
   RPC_USER=trinityuser
   RPC_PASSWORD=YOUR_SECURE_PASSWORD
   
   # Configure pool settings
   POOL_FEE=0.01  # 1% fee
   PAYOUT_THRESHOLD=0.1  # Minimum payout
   ```

7. **Start the pool**:
   ```bash
   sudo systemctl enable trinity-pool
   sudo systemctl start trinity-pool
   ```

8. **Configure firewall**:
   ```bash
   sudo ufw allow 80/tcp    # HTTP
   sudo ufw allow 3333/tcp  # Mining port
   sudo ufw enable
   ```

## Configuration

### Environment Variables

All configuration is done via environment variables in `.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| `ADMIN_USERNAME` | Admin panel username | `admin` |
| `ADMIN_PASSWORD` | Admin panel password | `trinity2024!` |
| `RPC_HOST` | Trinity daemon host | `127.0.0.1` |
| `RPC_PORT` | Trinity daemon RPC port | `62620` |
| `RPC_USER` | RPC username | `trinityuser` |
| `RPC_PASSWORD` | RPC password | `trinitypass` |
| `POOL_FEE` | Pool fee (0.01 = 1%) | `0.01` |
| `PAYOUT_THRESHOLD` | Minimum payout amount | `0.1` |
| `MIN_DIFFICULTY` | Minimum worker difficulty | `0.0001` |
| `WEB_PORT` | Web interface port | `8080` |
| `STRATUM_PORT` | Mining port | `3333` |

### Pool Settings

Edit `config/config.py` to change default settings:

- **Pool Fee**: Percentage taken from block rewards (default 1%)
- **Payout Threshold**: Minimum balance before payout
- **Minimum Difficulty**: Starting difficulty for new workers
- **Blocks Per Page**: Explorer pagination

## Usage

### Accessing the Pool

1. **Web Interface**: `http://YOUR_SERVER_IP`
2. **Admin Panel**: Click the lock icon at bottom-right, or visit `http://YOUR_SERVER_IP/admin/login`
3. **API Endpoint**: `http://YOUR_SERVER_IP/api/stats`

### Admin Login

Default credentials (CHANGE THESE!):
- Username: `admin`
- Password: `trinity2024!`

### Mining to the Pool

#### Using CPUMiner (SHA256D):
```bash
minerd -a sha256d -o http://YOUR_SERVER_IP:3333 -u YOUR_WALLET_ADDRESS -p x
```

#### Using CGMiner:
```bash
cgminer -o http://YOUR_SERVER_IP:3333 -u YOUR_WALLET_ADDRESS -p x --algo sha256d
```

**Important**: Your wallet address IS your worker name. All payments are sent to this address.

### Checking Worker Stats

1. Go to the pool homepage
2. Use the search bar to enter your wallet address
3. View your hashrate, shares, and earnings

## Payment System

### How It Works

1. **Share Submission**: Workers submit shares as they mine
2. **Block Found**: When a block is found, all shares since the last block are counted
3. **Payment Calculation**: Rewards are distributed proportionally based on share difficulty
4. **Automatic Payout**: When your balance reaches the threshold, payment is sent automatically

### Payment Schedule

- **Timing**: Payments processed every 5 minutes
- **Minimum**: 0.1 TRIN (configurable)
- **Pool Fee**: 1% (configurable)
- **Method**: Direct to wallet address (worker name)

## Administration

### Admin Dashboard

Access: `http://YOUR_SERVER_IP/admin`

Features:
- Real-time pool statistics
- Worker monitoring and management
- Block tracking
- Payment management
- Configuration settings

### Monitoring

Check pool status:
```bash
sudo systemctl status trinity-pool
```

View logs:
```bash
sudo journalctl -u trinity-pool -f
```

Application logs:
```bash
tail -f /opt/trinity-pool/logs/pool.log
```

### Maintenance

**Restart pool**:
```bash
sudo systemctl restart trinity-pool
```

**Update configuration**:
```bash
nano /opt/trinity-pool/.env
sudo systemctl restart trinity-pool
```

**Backup database**:
```bash
cp /opt/trinity-pool/data/pool.db /backup/location/
```

## API Documentation

### Public Endpoints

#### Get Pool Stats
```
GET /api/stats
```

Returns pool and network statistics.

#### Get Worker Stats
```
GET /api/worker/<address>
```

Returns statistics for a specific worker.

#### Submit Work (Mining)
```
POST /api/getwork
Content-Type: application/json

{
  "address": "worker_wallet_address",
  "data": "work_data" (optional, for submitting)
}
```

## Troubleshooting

### Pool won't start

1. Check Trinity daemon is running:
   ```bash
   trinity-cli getinfo
   ```

2. Verify RPC credentials in `.env` match `trinity.conf`

3. Check logs:
   ```bash
   sudo journalctl -u trinity-pool -n 50
   ```

### No blocks found

- Check network difficulty
- Verify miners are connected
- Ensure Trinity daemon is synchronized

### Workers not showing

- Verify wallet address is valid
- Check miner connection to correct port (3333)
- Review application logs for errors

### Payments not processing

- Ensure Trinity wallet has sufficient balance
- Check pending payments in admin panel
- Verify minimum payout threshold is reached

## Security

### Best Practices

1. **Change default credentials** immediately
2. **Use strong passwords** for admin and RPC
3. **Enable firewall** and only open required ports
4. **Regular backups** of database
5. **HTTPS** recommended for production (use Let's Encrypt)
6. **Keep software updated**

### Firewall Configuration

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS (if using SSL)
sudo ufw allow 3333/tcp  # Mining
sudo ufw enable
```

### SSL/HTTPS Setup (Recommended)

Using Let's Encrypt:
```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## Architecture

### Components

1. **Web Application** (Flask): Handles HTTP requests and web interface
2. **Pool Server**: Manages mining connections and share validation
3. **Database** (SQLite/PostgreSQL): Stores workers, shares, blocks, payments
4. **RPC Client**: Communicates with Trinity daemon
5. **Background Workers**: Process shares, calculate hashrates, send payments

### Database Schema

- **workers**: Miner information and statistics
- **shares**: Share submissions
- **blocks**: Blocks found by pool
- **payments**: Payment records
- **pool_stats**: Historical pool statistics

## Support

For issues, questions, or contributions:
- GitHub Issues: https://github.com/Sprouts-Network/Trinity/issues
- Repository: https://github.com/Sprouts-Network/Trinity

## License

This software is released under the MIT License. See COPYING for details.

## Credits

Built for Trinity cryptocurrency v2.0
Based on Bitcoin mining pool concepts
