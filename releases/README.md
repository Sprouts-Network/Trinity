# Trinity Releases

This directory contains official releases of Trinity cryptocurrency wallet.

## Latest Release: v2.0 (December 2025)

### Downloads
- [trinity-2.0.0-win64-build-kit.zip](v2.0/trinity-2.0.0-win64-build-kit.zip) (3.1 MB) - **Recommended**
  - Complete Windows build kit with source, scripts, and documentation
- [trinity-2.0.0-src.tar.gz](v2.0/trinity-2.0.0-src.tar.gz) (3.1 MB)
  - Source code package for Linux/Mac/custom builds

### Documentation
- [Release Notes](v2.0/RELEASE-NOTES.md) - What's new in v2.0
- [Quick Start Guide](v2.0/QUICKSTART.md) - Get building quickly
- [Building Instructions](v2.0/BUILDING.txt) - Detailed build guide
- [Manifest](v2.0/MANIFEST.txt) - Package contents
- [Checksums](v2.0/SHA256SUMS.txt) - File integrity verification

### What's New in v2.0
- ✅ BIP39 seed phrase generation for wallet creation
- ✅ Mandatory seed phrase confirmation for security
- ✅ Dark/Light theme support
- ✅ Modern UI components
- ✅ Enhanced build infrastructure
- ✅ Comprehensive Windows cross-compilation support

### Building
```bash
# Download and extract the build kit
unzip trinity-2.0.0-win64-build-kit.zip
cd trinity-2.0.0-win64-build-kit

# Extract source
tar xzf trinity-2.0.0-src.tar.gz

# Build (requires Windows dependencies)
cd trinity-2.0.0-src
../build-windows-exe.sh
```

See [QUICKSTART.md](v2.0/QUICKSTART.md) for detailed instructions.

### Verify Downloads
```bash
cd v2.0
sha256sum -c SHA256SUMS.txt
```

### System Requirements

**For Building:**
- Linux with MinGW-w64 (for cross-compilation)
- OR Windows with Qt Creator/MSVC/MinGW
- Qt 5.x
- Boost 1.50+
- BerkeleyDB 4.8
- OpenSSL 1.0.x

**For Running (once built):**
- Windows 7 or later (64-bit)
- 2 GB RAM minimum
- 500 MB disk space

## Previous Releases

### v1.0.0.1
Original release. See git history for details.

## Release Process

Trinity uses semantic versioning: MAJOR.MINOR.PATCH

1. **MAJOR** - Incompatible API changes or major features
2. **MINOR** - New functionality, backwards compatible
3. **PATCH** - Bug fixes, backwards compatible

## Support

- **GitHub Repository**: https://github.com/Sprouts-Network/Trinity
- **Issue Tracker**: https://github.com/Sprouts-Network/Trinity/issues
- **Documentation**: See README.md in repository root

## License

Trinity is released under the MIT License. See [COPYING](../COPYING) for details.

---

**Trinity v2.0** - Modern, Secure, Open Source Cryptocurrency Wallet
