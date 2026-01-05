# Trinity Mining Pool - Sample Miner Configurations

## CPU Mining with minerd (SHA256D)

### Basic Configuration
```bash
minerd -a sha256d \
  -o http://YOUR_POOL_IP:3333 \
  -u YOUR_WALLET_ADDRESS \
  -p x \
  --threads=4
```

### With Debug Output
```bash
minerd -a sha256d \
  -o http://YOUR_POOL_IP:3333 \
  -u YOUR_WALLET_ADDRESS \
  -p x \
  --threads=4 \
  --debug
```

### Background Mining
```bash
nohup minerd -a sha256d \
  -o http://YOUR_POOL_IP:3333 \
  -u YOUR_WALLET_ADDRESS \
  -p x \
  --threads=4 > miner.log 2>&1 &
```

## GPU Mining with CGMiner

### Basic Configuration
```bash
cgminer \
  -o http://YOUR_POOL_IP:3333 \
  -u YOUR_WALLET_ADDRESS \
  -p x \
  --algo sha256d
```

### With Intensity Settings
```bash
cgminer \
  -o http://YOUR_POOL_IP:3333 \
  -u YOUR_WALLET_ADDRESS \
  -p x \
  --algo sha256d \
  --intensity 13
```

## Configuration File Method

### Create miner.conf
```json
{
  "pools": [
    {
      "url": "http://YOUR_POOL_IP:3333",
      "user": "YOUR_WALLET_ADDRESS",
      "pass": "x"
    }
  ],
  "algo": "sha256d",
  "threads": 4,
  "quiet": false
}
```

### Run with Config
```bash
minerd --config=miner.conf
```

## Multiple Algorithm Support

Trinity supports three algorithms. Configure your miner for the one you prefer:

### SHA256D (Default - Bitcoin algorithm)
```bash
minerd -a sha256d -o http://YOUR_POOL_IP:3333 -u YOUR_WALLET_ADDRESS -p x
```

### Scrypt (Litecoin algorithm)
```bash
minerd -a scrypt -o http://YOUR_POOL_IP:3333 -u YOUR_WALLET_ADDRESS -p x
```

### Groestl
```bash
minerd -a groestl -o http://YOUR_POOL_IP:3333 -u YOUR_WALLET_ADDRESS -p x
```

## Windows Mining

### Using minerd.exe
```cmd
minerd.exe -a sha256d -o http://YOUR_POOL_IP:3333 -u YOUR_WALLET_ADDRESS -p x --threads=4
```

### Batch File (mine.bat)
```batch
@echo off
minerd.exe -a sha256d ^
  -o http://YOUR_POOL_IP:3333 ^
  -u YOUR_WALLET_ADDRESS ^
  -p x ^
  --threads=4
pause
```

## Testing Your Connection

### Check Pool Connectivity
```bash
# Test if pool is accessible
curl http://YOUR_POOL_IP:3333

# Check pool stats
curl http://YOUR_POOL_IP/api/stats
```

### Verify Your Worker
After mining for a few minutes:
```bash
# Replace with your address
curl http://YOUR_POOL_IP/api/worker/YOUR_WALLET_ADDRESS
```

## Performance Tips

### Optimal Thread Count
```bash
# For CPU mining, use number of cores minus 1
# Example for 8-core CPU:
minerd -a sha256d -o http://YOUR_POOL_IP:3333 -u YOUR_WALLET_ADDRESS -p x --threads=7
```

### CPU Affinity (Linux)
```bash
# Bind to specific cores
taskset -c 0-3 minerd -a sha256d -o http://YOUR_POOL_IP:3333 -u YOUR_WALLET_ADDRESS -p x --threads=4
```

### GPU Mining Tips
- Start with low intensity (10-13) and increase gradually
- Monitor temperature and adjust accordingly
- Use appropriate algorithm for your GPU model

## Monitoring Your Mining

### Check Hashrate
Your miner will display hashrate in the console:
```
[2024-01-05 12:34:56] thread 0: 123456 hashes, 1234.56 khash/s
[2024-01-05 12:34:56] accepted: 1/1 (100.00%), 4938.24 khash/s (yay!!!)
```

### Check Pool Stats
Visit: `http://YOUR_POOL_IP` and search for your wallet address

### API Check
```bash
curl http://YOUR_POOL_IP/api/worker/YOUR_WALLET_ADDRESS | jq
```

## Troubleshooting

### Connection Refused
```bash
# Check if pool is running
curl http://YOUR_POOL_IP

# Verify port 3333 is open
telnet YOUR_POOL_IP 3333
```

### Invalid Address
```bash
# Validate your wallet address with Trinity wallet
./trinity-cli validateaddress YOUR_WALLET_ADDRESS
```

### No Shares Accepted
- Check wallet address is correct
- Verify algorithm matches pool requirements
- Ensure sufficient CPU/GPU power
- Check miner logs for errors

### Low Hashrate
- Increase thread count
- Check CPU/GPU isn't throttling
- Update mining software to latest version
- Try different algorithm

## Example: Complete Mining Setup

### 1. Get Your Wallet Address
```bash
# In Trinity wallet
./trinity-cli getnewaddress
# Returns: TrinityAddressXXXXXXXXXXXXXXX
```

### 2. Download Miner
```bash
# Ubuntu/Debian
sudo apt-get install cpuminer

# Or compile from source
git clone https://github.com/pooler/cpuminer.git
cd cpuminer
./autogen.sh
./configure CFLAGS="-O3"
make
```

### 3. Start Mining
```bash
minerd -a sha256d \
  -o http://YOUR_POOL_IP:3333 \
  -u TrinityAddressXXXXXXXXXXXXXXX \
  -p x \
  --threads=4
```

### 4. Monitor Progress
- Console: Watch for "accepted" shares
- Web: Visit http://YOUR_POOL_IP
- Search: Enter your address to see stats

### 5. Receive Payments
- Automatic when threshold is reached
- Check pending balance on pool website
- Payments sent directly to your wallet address

## Support

For mining issues:
- Check pool status at http://YOUR_POOL_IP
- Review miner documentation
- Report pool issues on GitHub

---

**Remember**: Your wallet address IS your worker name. All rewards are paid directly to this address!
