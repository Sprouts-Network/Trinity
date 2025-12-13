#!/bin/bash
# Trinity Windows Build Script using qmake
# This script demonstrates how to build Trinity for Windows using qmake and MXE

set -e

echo "============================================="
echo "Trinity v2.0 - Windows Build with qmake"
echo "============================================="
echo ""

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MXE_PATH="${MXE_PATH:-/opt/mxe}"
BUILD_JOBS="${BUILD_JOBS:-$(nproc)}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_info() {
    echo -e "${YELLOW}INFO:${NC} $1"
}

print_step "Checking prerequisites..."

# Check if MXE is installed
if [ ! -d "$MXE_PATH" ]; then
    echo ""
    echo "ERROR: MXE not found at $MXE_PATH"
    echo ""
    echo "MXE (M cross environment) is required for Windows cross-compilation."
    echo ""
    echo "To install MXE:"
    echo "  sudo mkdir -p /opt/mxe"
    echo "  sudo chown \$(whoami) /opt/mxe"
    echo "  git clone https://github.com/mxe/mxe.git /opt/mxe"
    echo "  cd /opt/mxe"
    echo "  make MXE_TARGETS='x86_64-w64-mingw32.static' qtbase qttools boost db openssl miniupnpc"
    echo ""
    echo "This takes 2-4 hours on first build but provides all dependencies."
    echo ""
    echo "Alternatively, use the GitHub Actions workflow which handles this automatically."
    exit 1
fi

print_info "MXE found at: $MXE_PATH"

# Set up environment
export PATH="$MXE_PATH/usr/bin:$PATH"
export MXE_TARGET=x86_64-w64-mingw32.static

print_step "Finding qmake binary..."

# Find qmake
QMAKE_BIN=$(find "$MXE_PATH/usr" -path "*/qt5/bin/qmake" -type f 2>/dev/null | head -1)
if [ -z "$QMAKE_BIN" ]; then
    QMAKE_BIN=$(find "$MXE_PATH/usr" -name "${MXE_TARGET}-qmake-qt5" -type f 2>/dev/null | head -1)
fi
if [ -z "$QMAKE_BIN" ]; then
    QMAKE_BIN=$(find "$MXE_PATH/usr" -name "*qmake*" -type f 2>/dev/null | grep -i mingw | head -1)
fi

if [ -z "$QMAKE_BIN" ]; then
    echo "ERROR: qmake not found in MXE installation!"
    echo "Please ensure MXE is fully built with Qt support."
    exit 1
fi

print_info "Using qmake: $QMAKE_BIN"
$QMAKE_BIN --version
echo ""

# Change to project directory
cd "$PROJECT_ROOT"

print_step "Configuring Trinity with qmake..."

# Configure the project with qmake
# These options match what's expected by the .pro file
$QMAKE_BIN \
    USE_UPNP=1 \
    USE_QRCODE=0 \
    RELEASE=1 \
    trinity-qt.pro

print_info "Configuration complete. Makefile generated."
echo ""

print_step "Building Trinity for Windows..."
print_info "Using $BUILD_JOBS parallel jobs"
echo ""

# Build the project
make -j"$BUILD_JOBS"

print_step "Build complete!"
echo ""

# Check if executable was created
if [ -f "release/trinity-qt.exe" ]; then
    print_info "Windows executable created successfully!"
    echo ""
    echo "File details:"
    ls -lh release/trinity-qt.exe
    file release/trinity-qt.exe
    echo ""
    
    # Strip the executable to reduce size
    print_step "Stripping executable to reduce size..."
    STRIP_BIN=$(find "$MXE_PATH/usr" -name "${MXE_TARGET}-strip" -type f 2>/dev/null | head -1)
    if [ -n "$STRIP_BIN" ] && [ -x "$STRIP_BIN" ]; then
        $STRIP_BIN release/trinity-qt.exe
        print_info "Executable stripped"
        echo ""
        echo "Final file size:"
        ls -lh release/trinity-qt.exe
        echo ""
    fi
    
    print_step "SUCCESS!"
    echo ""
    echo "Windows executable: $PROJECT_ROOT/release/trinity-qt.exe"
    echo ""
    echo "You can now:"
    echo "  1. Test on Windows or with Wine"
    echo "  2. Create a distribution package"
    echo "  3. Upload to GitHub releases"
    echo ""
else
    echo "ERROR: Build completed but executable not found!"
    echo "Expected: release/trinity-qt.exe"
    exit 1
fi

print_step "Build summary"
echo ""
echo "Built with:"
echo "  Tool: qmake (Qt build system)"
echo "  Target: Windows x86_64 (static)"
echo "  Compiler: MinGW-w64 via MXE"
echo "  Qt: $(basename $(dirname $(dirname "$QMAKE_BIN")))"
echo ""
echo "Features:"
echo "  ✓ UPnP support"
echo "  ✓ Static linking (standalone .exe)"
echo "  ✓ ASLR and DEP security features"
echo "  ✓ Large address aware"
echo ""
