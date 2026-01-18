# Trinity Linux ISO & Bootable USB Guide

This guide describes how to create a bootable Linux ISO that ships Trinity with a built-in web GUI, a local stratum server for miner management, and the block explorer + JSON API from `pool-explorer`.

## What the ISO provides

- **Trinity daemon** (`trinityd` + `trinity-cli`) with RPC enabled
- **Web GUI** (pool dashboard + admin panel)
- **Local mining gateway** (stratum server for solo or pooled mining)
- **Block explorer** with dynamic API endpoints:
  - `GET /api/stats`
  - `GET /api/worker/<address>`
  - `POST /api/getwork`

## Build prerequisites

- Debian/Ubuntu build host
- `live-build`, `xorriso`, `squashfs-tools`, `debootstrap`
- Trinity binaries built for Linux

Install the build tools:

```bash
sudo apt-get update
sudo apt-get install -y live-build xorriso squashfs-tools debootstrap
```

## ISO staging layout

The ISO should include:

- `/usr/local/bin/trinityd` and `/usr/local/bin/trinity-cli`
- `/opt/trinity-pool` (copy of `pool-explorer` with a virtualenv)
- `/etc/trinity/trinity.conf` (RPC enabled)
- `/etc/trinity/pool.env` (environment file for pool-explorer)
- Systemd units from this directory:
  - `contrib/iso/trinityd.service`
  - `contrib/iso/trinity-pool.service`

### Example Trinity config (`/etc/trinity/trinity.conf`)

```ini
server=1
rpcuser=trinityuser
rpcpassword=YOUR_SECURE_RPC_PASSWORD_HERE
rpcallowip=127.0.0.1
rpcport=62620
# Optional: enable solo mining on boot
# gen=1
```

### Pool/explorer environment file

Copy the template and adjust it for the ISO image:

```bash
sudo mkdir -p /etc/trinity
sudo cp contrib/iso/pool.env.example /etc/trinity/pool.env
sudo nano /etc/trinity/pool.env
```

## Building the ISO

1. **Create a staging root** (example uses `/tmp/trinity-iso-root`).
2. **Install Trinity + pool-explorer** inside the staging root.
3. **Copy the systemd unit files** from `contrib/iso/` into `/etc/systemd/system/`.
4. **Enable services** so they start automatically at boot.
5. **Use live-build** to package the staging root into an ISO.

A minimal live-build flow looks like:

```bash
mkdir -p /tmp/trinity-live
cd /tmp/trinity-live

lb config \
  --binary-images iso-hybrid \
  --distribution bookworm \
  --archive-areas "main contrib non-free-firmware"

mkdir -p config/includes.chroot
sudo rsync -a /tmp/trinity-iso-root/ config/includes.chroot/

sudo lb build
```

The resulting ISO will be in `live-image-amd64.hybrid.iso`.

## Bootable USB creation

Write the ISO to a USB drive (replace `/dev/sdX`):

```bash
lsblk
echo "WARNING: double-check /dev/sdX - this will erase the target disk"
sudo dd if=live-image-amd64.hybrid.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## Mining modes

- **Solo mining**: set `POOL_ADDRESS` to your wallet address and `POOL_FEE=0` in `pool.env`, then point miners to the local stratum server (`stratum+tcp://<iso-ip>:3333`).
- **Pool mining**: keep the local stratum server enabled for a private pool, or disable `trinity-pool.service` and point miners directly to an external pool.

## Web GUI & explorer access

Once the ISO boots and services are enabled:

- Web UI: `http://<iso-ip>:8080`
- Admin panel: `http://<iso-ip>:8080/admin`
- API: `http://<iso-ip>:8080/api/stats`

## Service enablement

Inside the ISO root (or after booting):

```bash
sudo systemctl enable trinityd.service
sudo systemctl enable trinity-pool.service
```

## Notes

- Use `pool-explorer/setup.sh` as a reference for dependency installation and virtualenv setup.
- For remote access, open ports `8080` (web UI) and `3333` (stratum).
