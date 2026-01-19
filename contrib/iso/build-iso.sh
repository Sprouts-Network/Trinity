#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORKDIR="${WORKDIR:-/tmp/trinity-iso-build}"
STAGE_ROOT="${STAGE_ROOT:-${WORKDIR}/stage}"
LIVEBUILD_DIR="${LIVEBUILD_DIR:-${WORKDIR}/live-build}"
OUTPUT_DIR="${OUTPUT_DIR:-${REPO_ROOT}/dist}"
ISO_NAME="${ISO_NAME:-trinity-linux.iso}"
BUILD_TRINITY="${BUILD_TRINITY:-1}"
BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"
RPC_PASSWORD="${RPC_PASSWORD:-CHANGE_ME_SECURE_RPC_PASSWORD}"

if [[ "${WORKDIR}" != /tmp/* ]]; then
  echo "WORKDIR must be under /tmp (current: ${WORKDIR})" >&2
  exit 1
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

require_command lb
require_command rsync
require_command python3
require_command sudo

if ! sudo -n true 2>/dev/null; then
  echo "This script requires sudo access for live-build and rsync." >&2
  sudo -v
fi

rm -rf "${WORKDIR}"
mkdir -p "${STAGE_ROOT}" "${OUTPUT_DIR}" "${LIVEBUILD_DIR}"

mkdir -p \
  "${STAGE_ROOT}/etc/systemd/system" \
  "${STAGE_ROOT}/etc/trinity" \
  "${STAGE_ROOT}/opt/trinity-pool" \
  "${STAGE_ROOT}/usr/local/bin" \
  "${STAGE_ROOT}/var/lib/trinity"

if [[ "${BUILD_TRINITY}" == "1" ]]; then
  echo "Building trinityd..."
  (cd "${REPO_ROOT}/src" && make -f makefile.unix USE_UPNP=- -j"${BUILD_JOBS}")
  install -m 0755 "${REPO_ROOT}/src/trinityd" "${STAGE_ROOT}/usr/local/bin/trinityd"
  if [[ -f "${REPO_ROOT}/src/trinity-cli" ]]; then
    install -m 0755 "${REPO_ROOT}/src/trinity-cli" "${STAGE_ROOT}/usr/local/bin/trinity-cli"
  fi
fi

rsync -a --delete --exclude '__pycache__' --exclude '*.pyc' \
  "${REPO_ROOT}/pool-explorer/" "${STAGE_ROOT}/opt/trinity-pool/"

python3 -m venv "${STAGE_ROOT}/opt/trinity-pool/venv"
"${STAGE_ROOT}/opt/trinity-pool/venv/bin/pip" install --no-cache-dir --upgrade pip
"${STAGE_ROOT}/opt/trinity-pool/venv/bin/pip" install --no-cache-dir -r "${STAGE_ROOT}/opt/trinity-pool/requirements.txt"

install -m 0644 "${REPO_ROOT}/contrib/iso/trinityd.service" \
  "${STAGE_ROOT}/etc/systemd/system/trinityd.service"
install -m 0644 "${REPO_ROOT}/contrib/iso/trinity-pool.service" \
  "${STAGE_ROOT}/etc/systemd/system/trinity-pool.service"
install -m 0644 "${REPO_ROOT}/contrib/iso/pool.env.example" \
  "${STAGE_ROOT}/etc/trinity/pool.env.example"

cat > "${STAGE_ROOT}/etc/trinity/trinity.conf" <<'TRINITYCONF'
server=1
rpcuser=trinityuser
rpcpassword=__RPC_PASSWORD__
rpcallowip=127.0.0.1
rpcport=62620
TRINITYCONF

sed -i "s#__RPC_PASSWORD__#${RPC_PASSWORD}#" "${STAGE_ROOT}/etc/trinity/trinity.conf"

if [[ "${RPC_PASSWORD}" == "CHANGE_ME_SECURE_RPC_PASSWORD" ]]; then
  echo "WARNING: Update /etc/trinity/trinity.conf with a secure rpcpassword before booting the ISO." >&2
fi

cd "${LIVEBUILD_DIR}"

lb config \
  --binary-images iso-hybrid \
  --distribution bookworm \
  --archive-areas "main contrib non-free-firmware"

mkdir -p config/includes.chroot
sudo rsync -a "${STAGE_ROOT}/" config/includes.chroot/

sudo lb build

cp "${LIVEBUILD_DIR}/live-image-amd64.hybrid.iso" "${OUTPUT_DIR}/${ISO_NAME}"

echo "ISO created at ${OUTPUT_DIR}/${ISO_NAME}"
