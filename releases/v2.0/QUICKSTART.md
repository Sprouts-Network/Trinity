# Trinity v2.0 Windows Release - Quick Start Guide

## What's Included

This release package provides everything you need to build Trinity for Windows:

### 📦 Release Files

1. **trinity-2.0.0-win64-build-kit.zip** (Recommended)
   - Complete source code
   - Automated build script
   - Documentation
   - Build instructions
   
2. **trinity-2.0.0-src.tar.gz**
   - Source code only
   - For custom builds

## Option 1: Using the Build Kit (Easiest)

### Prerequisites
You need a Linux system with MinGW cross-compiler and Windows dependencies:
- MinGW-w64
- Qt 5.x for Windows (MinGW build)
- Boost 1.50+
- BerkeleyDB 4.8
- OpenSSL 1.0.x

### Steps
```bash
# 1. Download and extract
unzip trinity-2.0.0-win64-build-kit.zip
cd trinity-2.0.0-win64-build-kit

# 2. Extract source
tar xzf trinity-2.0.0-src.tar.gz
cd trinity-2.0.0-src

# 3. Run build script
../build-windows-exe.sh

# 4. Find your executable
# If successful: release/trinity-qt.exe
```

## Option 2: Using Pre-built Dependencies

If you have access to pre-built Windows dependencies:

```bash
export QT_WIN=/path/to/qt-windows
export BOOST_ROOT=/path/to/boost-windows
export BDB_ROOT=/path/to/berkeleydb-windows
export OPENSSL_ROOT=/path/to/openssl-windows

./build-windows-exe.sh
```

## Option 3: Docker Build (Recommended for Production)

```bash
# 1. Extract the source from the build kit
tar xzf trinity-2.0.0-src.tar.gz

# 2. Use the Dockerfile
cd trinity-2.0.0-src
docker build -f Dockerfile.windows -t trinity-builder .

# 3. Build inside container (after setting up dependencies)
docker run -v $(pwd):/build trinity-builder
```

## Option 4: GitHub Actions (Automated)

The source includes a GitHub Actions workflow that can build automatically:

1. Fork the repository
2. Configure dependency downloads in `.github/workflows/build-windows.yml`
3. Push tag `v2.0`
4. Download built executable from Actions artifacts

## Getting Windows Dependencies

### Quick Method (Recommended)
Use pre-built packages:
- **Qt**: Download Qt for Windows (MinGW) from https://www.qt.io/download
- **Boost**: Pre-built MinGW packages available on SourceForge
- **Others**: Check MXE (M cross environment) for pre-built libraries

### Build From Source
See `BUILDING.txt` in the build kit for complete instructions on compiling each dependency.

## Verification

After downloading, verify file integrity:
```bash
sha256sum -c SHA256SUMS.txt
```

Expected checksums are in `SHA256SUMS.txt`.

## What You'll Get

After successful build:
- **trinity-qt.exe** - Windows executable (GUI wallet)
- Approximately 20-30 MB (depending on static linking)

## Common Issues

### "Dependencies not found"
- Ensure all dependency paths are correct
- Check that you have Windows (MinGW) builds, not Linux builds

### "Qt not found"
- Install Qt for Windows (MinGW 64-bit build)
- Set QT_WIN environment variable

### "Linker errors"
- Verify all libraries are built for Windows x64
- Check MinGW version compatibility

## Support

- **Documentation**: See `BUILDING.txt` for detailed instructions
- **GitHub Issues**: https://github.com/Sprouts-Network/Trinity/issues
- **Release Notes**: See `RELEASE-NOTES.md` for full details

## Alternative: Build on Windows Natively

You can also build directly on Windows using:
1. Qt Creator
2. MSVC or MinGW-w64
3. Visual Studio

Open `trinity-qt.pro` in Qt Creator and build.

## Time Estimates

| Method | First-time Setup | Build Time |
|--------|------------------|------------|
| Pre-built deps | 30 minutes | 15 minutes |
| Docker (prepared) | 1 hour | 20 minutes |
| From source deps | 2-3 hours | 3-4 hours |
| GitHub Actions | 2 hours setup | Automated |

## License

Trinity is released under the MIT License. See COPYING in the source package.

---

**Ready to build Trinity v2.0 for Windows!**

For questions or issues, visit: https://github.com/Sprouts-Network/Trinity
