#!/usr/bin/env bash
# Build a bootable Ubuntu (noble 24.04) ISO with a lightweight GUI, Trinity daemon/CLI,
# Trinity-Qt wallet, local stratum gateway, pool-explorer web GUI + API, and systemd services.
# The default desktop is Xubuntu (xubuntu-desktop) to be "not TOO minimal but still minimal".
#
# Usage:
#   ./contrib/iso/build-ubuntu-gui-iso.sh
#
# Environment overrides:
#   UBUNTU_CODENAME=noble           # Ubuntu release (noble=24.04, jammy=22.04)
#   GUI_TASK=xubuntu-desktop        # Desktop meta-package (e.g., xubuntu-desktop, ubuntu-desktop-minimal, ubuntu-desktop)
#   STAGING_ROOT=/tmp/trinity-iso-root
#   LIVE_DIR=/tmp/trinity-live
#   OUTPUT_ISO=dist/trinity-linux-ubuntu.iso
#   RPC_PASSWORD=<secure password>  # RPC password; auto-generated if not set
#
# Notes:
# - Run from repo root (Sprouts-Network/Trinity).
# - Requires sudo privileges.
# - Attempts to build Trinity daemon/CLI + Qt wallet if sources support Autotools.
# - If build fails, place prebuilt binaries at:
#     ./dist/linux/trinityd, ./dist/linux/trinity-cli, ./dist/linux/Trinity-qt
#   and the script will copy them.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UBUNTU_CODENAME="${UBUNTU_CODENAME:-noble}"
GUI_TASK="${GUI_TASK:-xubuntu-desktop}"
STAGING_ROOT="${STAGING_ROOT:-/tmp/trinity-iso-root}"
LIVE_DIR="${LIVE_DIR:-/tmp/trinity-live}"
OUTPUT_ISO="${OUTPUT_ISO:-dist/trinity-linux-ubuntu.iso}"
DIST_DIR="${REPO_ROOT}/dist"
ISO_CREDENTIALS="${DIST_DIR}/iso-credentials.txt"

# Ensure dist directory exists
mkdir -p "${DIST_DIR}"

echo "==> Installing host build dependencies (requires sudo)"
sudo apt-get update
sudo apt-get install -y \
  live-build xorriso squashfs-tools debootstrap rsync \
  build-essential libtool autotools-dev automake pkg-config cmake bsdmainutils \
  libevent-dev libboost-system-dev libboost-filesystem-dev libboost-chrono-dev \
  libboost-test-dev libboost-thread-dev libdb-dev libdb++-dev libminiupnpc-dev \
  libzmq3-dev \
  qtbase5-dev qttools5-dev qttools5-dev-tools libqt5svg5-dev \
  python3-venv python3-pip git curl jq

# Generate or capture RPC password
RPC_PASSWORD="${RPC_PASSWORD:-}"
if [[ -z "${RPC_PASSWORD}" ]]; then
  RPC_PASSWORD="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24)"
fi
printf "RPC_PASSWORD=%s\n" "${RPC_PASSWORD}" > "${ISO_CREDENTIALS}"
echo "==> Wrote ${ISO_CREDENTIALS}"

echo "==> Preparing staging root at ${STAGING_ROOT}"
sudo rm -rf "${STAGING_ROOT}"
sudo mkdir -p "${STAGING_ROOT}/usr/local/bin"
sudo mkdir -p "${STAGING_ROOT}/opt/trinity-pool"
sudo mkdir -p "${STAGING_ROOT}/etc/trinity"
sudo mkdir -p "${STAGING_ROOT}/var/lib/trinity"
sudo mkdir -p "${STAGING_ROOT}/etc/systemd/system"
sudo mkdir -p "${STAGING_ROOT}/etc/systemd/system/multi-user.target.wants"

# Try to build Trinity from source (daemon/CLI + Qt)
build_from_source=false
if [[ -f "${REPO_ROOT}/autogen.sh" ]]; then
  build_from_source=true
fi

if "${build_from_source}"; then
  echo "==> Building Trinity from source"
  pushd "${REPO_ROOT}"
  bash autogen.sh
  ./configure --with-gui=qt5 || true
  make -j"$(nproc)" || true
  popd
fi

# Copy binaries, preferring build output; fallback to dist folder
copy_bin() {
  local src="$1"
  local dst="$2"
  if [[ -f "${src}" ]]; then
    sudo install -m 0755 "${src}" "${dst}"
    echo "Installed $(basename "${src}") -> ${dst}"
    return 0
  fi
  return 1
}

echo "==> Installing Trinity binaries into staging"
copy_bin "${REPO_ROOT}/src/trinityd" "${STAGING_ROOT}/usr/local/bin/trinityd" || \
copy_bin "${REPO_ROOT}/dist/linux/trinityd" "${STAGING_ROOT}/usr/local/bin/trinityd" || \
{ echo "WARNING: trinityd not found; ensure binaries are built or placed in dist/linux"; }

copy_bin "${REPO_ROOT}/src/trinity-cli" "${STAGING_ROOT}/usr/local/bin/trinity-cli" || \
copy_bin "${REPO_ROOT}/dist/linux/trinity-cli" "${STAGING_ROOT}/usr/local/bin/trinity-cli" || \
{ echo "WARNING: trinity-cli not found; ensure binaries are built or placed in dist/linux"; }

# Qt wallet binary
copy_bin "${REPO_ROOT}/src/qt/Trinity-qt" "${STAGING_ROOT}/usr/local/bin/Trinity-qt" || \
copy_bin "${REPO_ROOT}/dist/linux/Trinity-qt" "${STAGING_ROOT}/usr/local/bin/Trinity-qt" || \
{ echo "WARNING: Trinity-qt not found; ensure Qt wallet is built or placed in dist/linux"; }

# Optional desktop entry for Qt wallet
echo "==> Adding Trinity-Qt desktop entry"
sudo mkdir -p "${STAGING_ROOT}/usr/share/applications"
sudo tee "${STAGING_ROOT}/usr/share/applications/trinity-qt.desktop" >/dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=Trinity Wallet (Qt)
Comment=Launch the Trinity Qt wallet
Exec=/usr/local/bin/Trinity-qt
Icon=wallet
Terminal=false
Categories=Finance;Network;
EOF

# Configure Trinity daemon
echo "==> Writing /etc/trinity/trinity.conf"
sudo tee "${STAGING_ROOT}/etc/trinity/trinity.conf" >/dev/null <<EOF
server=1
rpcuser=trinityuser
rpcpassword=${RPC_PASSWORD}
rpcallowip=127.0.0.1
rpcport=62620
# gen=1
EOF

# Pool/explorer environment
if [[ -f "${REPO_ROOT}/contrib/iso/pool.env.example" ]]; then
  sudo cp "${REPO_ROOT}/contrib/iso/pool.env.example" "${STAGING_ROOT}/etc/trinity/pool.env"
else
  echo "==> Creating default /etc/trinity/pool.env"
  sudo tee "${STAGING_ROOT}/etc/trinity/pool.env" >/dev/null <<'EOF'
# Copy from contrib/iso/pool.env.example in the repo and customize:
WEB_HOST=0.0.0.0
WEB_PORT=8080
STRATUM_PORT=3333
POOL_ADDRESS=CHANGE_ME_WALLET_ADDRESS
POOL_FEE=0
RPC_USER=trinityuser
RPC_PASSWORD=CHANGE_ME
EOF
fi

# Deploy pool-explorer into staging and set up venv
if [[ -d "${REPO_ROOT}/pool-explorer" ]]; then
  echo "==> Installing pool-explorer into staging"
  sudo rsync -a --delete "${REPO_ROOT}/pool-explorer/" "${STAGING_ROOT}/opt/trinity-pool/"
  # Create venv and install requirements inside staging
  sudo chroot "${STAGING_ROOT}" /bin/bash -c "
    set -e
    apt-get update || true
    apt-get install -y python3-venv python3-pip || true
    python3 -m venv /opt/trinity-pool/.venv
    . /opt/trinity-pool/.venv/bin/activate
    if [ -f /opt/trinity-pool/requirements.txt ]; then
      pip install --upgrade pip
      pip install -r /opt/trinity-pool/requirements.txt
    fi
    deactivate
  " || echo 'WARNING: pool-explorer venv setup inside chroot may be deferred to first boot.'
else
  echo "WARNING: pool-explorer directory not found; web GUI/APIs will be unavailable."
fi

# Systemd units
for unit in trinityd.service trinity-pool.service; do
  if [[ -f "${REPO_ROOT}/contrib/iso/${unit}" ]]; then
    sudo cp "${REPO_ROOT}/contrib/iso/${unit}" "${STAGING_ROOT}/etc/systemd/system/${unit}"
    # Enable by creating symlink in multi-user target wants
    sudo ln -sf "/etc/systemd/system/${unit}" \
      "${STAGING_ROOT}/etc/systemd/system/multi-user.target.wants/${unit}"
  else
    echo "WARNING: Missing unit ${unit} in contrib/iso"
  fi
done

# Live-build setup for Ubuntu GUI ISO
echo "==> Configuring live-build for Ubuntu ${UBUNTU_CODENAME} with GUI task ${GUI_TASK}"
sudo rm -rf "${LIVE_DIR}"
mkdir -p "${LIVE_DIR}"
pushd "${LIVE_DIR}"

lb config \
  --binary-images iso-hybrid \
  --distribution "${UBUNTU_CODENAME}" \
  --archive-areas "main restricted universe multiverse" \
  --mirror-bootstrap "http://archive.ubuntu.com/ubuntu/" \
  --mirror-binary "http://archive.ubuntu.com/ubuntu/"

# Include the staging root
mkdir -p config/includes.chroot
sudo rsync -a "${STAGING_ROOT}/" "config/includes.chroot/"

# Include desktop meta-packages via package-lists
mkdir -p config/package-lists
cat > config/package-lists/gui.list.chroot <<EOF
${GUI_TASK}
# Make the GUI practical but lean
xfce4-terminal
thunar
firefox
network-manager
openssh-server
ufw
curl
wget
vim
EOF

echo "==> Building ISO (this may take a while)"
sudo lb build

popd

# Move resulting ISO to dist with a friendly name
if [[ -f "${LIVE_DIR}/live-image-amd64.hybrid.iso" ]]; then
  mv "${LIVE_DIR}/live-image-amd64.hybrid.iso" "${OUTPUT_ISO}"
  echo "==> ISO ready: ${OUTPUT_ISO}"
else
  echo "ERROR: live-image-amd64.hybrid.iso not found in ${LIVE_DIR}"
  exit 1
fi

echo "==> Done."
echo "Web UI will be available at http://<iso-ip>:8080"
echo "Qt wallet installed as /usr/local/bin/Trinity-qt and menu entry Trinity Wallet (Qt)"
