# Trinity v2.0 Release Notes

## Overview
Trinity v2.0 is a major release featuring modern UI improvements, enhanced security through BIP39 seed phrase support, and comprehensive build infrastructure.

## New Features

### Security & Wallet Management
- **BIP39 Seed Phrase Generation**: Secure 24-word mnemonic phrases for wallet creation
- **Mandatory Seed Confirmation**: Users must confirm their seed phrase before wallet creation completes
- **Enhanced Wallet Security**: Industry-standard BIP39 implementation

### User Interface
- **Dark/Light Theme Support**: Professional themes with QSS stylesheets
- **Modern Wallet Creation Dialog**: Improved onboarding experience
- **Enhanced UI Components**: Modernized interface throughout the application

### Build Infrastructure
- **Windows Cross-Compilation**: Complete MinGW build system
- **Docker Support**: Reproducible build environment
- **GitHub Actions CI/CD**: Automated build workflows
- **Comprehensive Documentation**: Detailed build guides for all platforms

## Downloads

### Windows
- **trinity-2.0.0-win64-build-kit.zip** (3.1 MB)
  - Complete source code
  - Windows build scripts
  - Build instructions
  - Ready for compilation with Windows dependencies

### Source
- **trinity-2.0.0-src.tar.gz** (3.1 MB)
  - Complete source code
  - All build configurations
  - Documentation

## Building from Source

### Windows
The Windows build requires:
- MinGW-w64 cross-compiler (or native Windows build tools)
- Qt 5.x for Windows
- Boost 1.50+
- BerkeleyDB 4.8
- OpenSSL 1.0.x

See `BUILDING.txt` in the build kit for detailed instructions.

Quickstart:
```bash
unzip trinity-2.0.0-win64-build-kit.zip
cd trinity-2.0.0-win64-build-kit
./build-windows-exe.sh  # Requires dependencies
```

### Linux
```bash
tar xzf trinity-2.0.0-src.tar.gz
cd trinity-2.0.0-src
qmake USE_UPNP=- trinity-qt.pro
make -j$(nproc)
```

### Alternative Build Methods
1. **Docker**: Use provided Dockerfile.windows for isolated builds
2. **GitHub Actions**: Automated builds on tag push
3. **Gitian**: Deterministic builds (see contrib/gitian-descriptors/)

## Technical Details

### Version Information
- **Version**: 2.0.0
- **Previous Version**: 1.0.0.1
- **Release Date**: December 2025
- **Git Tag**: v2.0

### Files Changed
- Core: 8 files modified
- New: 15 files added
- Build: Complete Windows infrastructure
- Documentation: 5 comprehensive guides

### Commits
- Merged upgrade5 branch (2 commits)
- Build infrastructure (3 commits)
- Documentation (3 commits)
- Version updates (1 commit)

## About Windows Executable Compilation

**Important Note**: Compiling a complete Windows executable (.exe) requires cross-compiled dependencies for Qt, Boost, BerkeleyDB, and OpenSSL. This process typically takes 2-4 hours for a complete build from source.

The release package includes:
- ✅ Complete source code
- ✅ Build scripts for Windows
- ✅ Comprehensive build documentation
- ✅ Docker and CI/CD configurations

For production Windows builds, we recommend:
1. Using pre-built dependency packages
2. Setting up a dedicated build server
3. Using the provided GitHub Actions workflow
4. Following the Gitian deterministic build process

The build infrastructure is complete and ready to produce Windows executables once dependencies are available.

## Upgrade Notes

This is a major version update from 1.0.x to 2.0.0. 

**Important**: When upgrading, you will be prompted to:
1. Create a new wallet OR
2. Confirm your existing wallet's seed phrase

This is a one-time security enhancement to ensure all wallets have backed-up seed phrases.

## Known Issues

None identified in v2.0.0. Please report any issues at:
https://github.com/Sprouts-Network/Trinity/issues

## Contributors

This release includes contributions merged from the upgrade5 branch, featuring:
- Modern UI components
- BIP39 implementation
- Theme system
- Build infrastructure improvements

Special thanks to all contributors who helped test and review these changes.

## Verification

To verify this release:
```bash
# Check version
./trinity-qt --version

# Verify git tag
git tag -v v2.0

# Check source integrity
sha256sum trinity-2.0.0-src.tar.gz
```

## Support

- **GitHub**: https://github.com/Sprouts-Network/Trinity
- **Issues**: https://github.com/Sprouts-Network/Trinity/issues
- **Documentation**: See README.md and docs/ directory

## License

Trinity is released under the MIT License. See COPYING for full license text.

---

**Trinity v2.0** - Enhanced Security, Modern Interface, Ready to Build
