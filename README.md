Trinity v2.0
===================================

A cryptocurrency wallet with modern features and multi-algorithm mining support.

## What is Trinity?

Trinity is a cryptocurrency that includes three mining algorithms (sha256d, scrypt, groestl) with random block rewards and modern wallet features.

### New in Version 2.0

- ✨ **Modern Wallet Creation** - BIP39 seed phrase support for secure wallet backup
- 🎨 **Theme Support** - Dark and Light themes for comfortable viewing
- 🔐 **Enhanced Security** - Modern cryptography and secure wallet generation
- 💎 **Modernized UI** - Updated interface with improved user experience
- 📱 **Better Onboarding** - Guided wallet creation with seed phrase confirmation

### Mining Pool & Block Explorer

Trinity now includes a complete mining pool and block explorer solution! 

- ⛏️ **Mining Pool** - Easy-to-deploy pool server with automatic payments
- 🔍 **Block Explorer** - Web-based blockchain explorer with search
- 👥 **Worker Management** - Track individual miner statistics
- 💰 **Automatic Payments** - Proportional rewards paid per block
- 🎛️ **Admin Panel** - Full administrative control and monitoring

**Quick Start**: See [POOL-DEPLOYMENT.md](POOL-DEPLOYMENT.md) for setup instructions.

## Download Windows Executable

### Quick Download

Get the pre-built Windows executable:

1. Go to [Actions tab](../../actions/workflows/build-windows-mxe.yml)
2. Click the latest successful workflow run
3. Download `trinity-windows-x64-package` artifact
4. Extract and run `trinity-qt.exe`

Or manually trigger a build:
1. Go to [Actions](../../actions/workflows/build-windows-mxe.yml)
2. Click "Run workflow"
3. Wait for completion (~2-4 hours first time, ~15 min with cache)
4. Download the artifact

### System Requirements

- Windows 7 or later
- 64-bit Windows
- 2GB RAM minimum
- 500MB disk space

For detailed download and build instructions, see [WINDOWS-DOWNLOAD-GUIDE.md](WINDOWS-DOWNLOAD-GUIDE.md)

## Building from Source

### Windows Build

See [BUILDING-WINDOWS.md](BUILDING-WINDOWS.md) for comprehensive Windows build instructions.

Quick options:
- **GitHub Actions** (Recommended) - Automated builds with MXE
- **MXE** - Cross-compile from Linux with full toolchain
- **Pre-built Dependencies** - Use existing Windows libraries

### Linux Build

Dependencies:
```bash
sudo apt-get install \
    build-essential \
    libboost-all-dev \
    libssl-dev \
    libdb++-dev \
    qtbase5-dev \
    qttools5-dev-tools
```

Build:
```bash
qmake USE_UPNP=- trinity-qt.pro
make -j$(nproc)
./trinity-qt
```

### macOS Build

See documentation in `contrib/macdeploy/` directory.

## Specifications

- **Mining Algorithms**: sha256d (default), scrypt, groestl
- **Block Rewards**: Random rewards for interesting mining dynamics
- **Consensus**: Proof of Work based
- **Version**: 2.0.0

## Verification

To verify the build process is working:

```bash
./verify-windows-build.sh
```

This script checks:
- Project structure
- Build environment
- Workflow configuration
- Documentation completeness

## Documentation

### Wallet & Mining
- [Windows Build Guide](BUILDING-WINDOWS.md)
- [Windows Download Guide](WINDOWS-DOWNLOAD-GUIDE.md)
- [Build Status](BUILD-STATUS.md)
- [Installation Instructions](INSTALL)

### Mining Pool & Explorer
- [Pool Deployment Guide](POOL-DEPLOYMENT.md) - Complete setup instructions
- [Pool Implementation Details](POOL-IMPLEMENTATION.md) - Technical overview
- [Pool Documentation](pool-explorer/README.md) - Comprehensive guide
- [Quick Start Guide](pool-explorer/QUICKSTART.md) - Fast setup
- [Mining Configuration](pool-explorer/MINING-GUIDE.md) - Miner setup

## Support

- **Issues**: [GitHub Issues](../../issues)
- **Source Code**: [GitHub Repository](../../)

## License

Trinity is released under the terms of the MIT license. See [COPYING](COPYING) for more information or visit http://opensource.org/licenses/MIT.
