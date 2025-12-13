# Using Pre-built Cross-Compilation Libraries for Trinity

This document explains available pre-built cross-compilation libraries for Windows builds.

## Available Options

### 1. MSYS2 MinGW Packages (Recommended for Quick Setup)

**Repository:** https://repo.msys2.org/mingw/mingw64/

**What it provides:**
- Pre-built Qt5 for MinGW64
- Pre-built Boost libraries
- Pre-built OpenSSL
- Pre-built BerkeleyDB
- Pre-built miniupnpc

**Advantages:**
- ✅ Already compiled and ready to download
- ✅ Updated regularly
- ✅ Easy to integrate
- ✅ Smaller downloads than building from source

**How to use:**
1. Download packages from MSYS2 repository
2. Extract to a MinGW prefix directory
3. Configure qmake with paths to the extracted libraries
4. Build Trinity

**Implementation:**
A new workflow has been created: `.github/workflows/build-windows-msys2.yml`

This workflow automatically downloads and uses MSYS2 packages.

**Limitations:**
- Package versions change over time (URLs need maintenance)
- May need adjustments for static linking preferences
- BerkeleyDB version might differ from ideal (4.8)

### 2. Bitcoin Core 'depends' System (Best for Deterministic Builds)

**Repository:** https://github.com/bitcoin/bitcoin/tree/master/depends

**What it provides:**
- Boost (exactly the version needed)
- BerkeleyDB 4.8 (perfect for Trinity)
- OpenSSL
- Qt 5.x
- miniupnpc
- All built for cross-compilation

**Advantages:**
- ✅ Designed specifically for cryptocurrency wallets
- ✅ Deterministic builds (reproducible)
- ✅ Uses correct BerkeleyDB 4.8 version
- ✅ Well-maintained by Bitcoin Core team
- ✅ Can be adapted to Trinity

**How to integrate:**
1. Copy the `depends` directory from Bitcoin Core
2. Adapt Makefiles for Trinity's needs
3. Run `make HOST=x86_64-w64-mingw32` once (~30-45 min)
4. Cache the built dependencies
5. Use in subsequent builds (~5 min)

**Status:**
Not yet implemented, but highly recommended for future enhancement.

### 3. MXE Cached Artifacts (Currently Used)

**What it is:**
The "Fast Windows Build" workflow already caches the entire MXE toolchain after the first build.

**Location:**
GitHub Actions cache (automatic)

**How it works:**
- First run: Builds MXE from source (~2 hours)
- Caches entire `/opt/mxe` directory (~3-5 GB)
- Subsequent runs: Restores cache (~15 minutes total build time)

**Status:**
✅ Already implemented and working in `build-windows-fast.yml`

### 4. Vcpkg (Alternative)

**Repository:** https://github.com/microsoft/vcpkg

**What it provides:**
- Qt, Boost, OpenSSL, BerkeleyDB for various platforms
- Binary caching support
- Package manager for C++ libraries

**Limitations:**
- Primarily designed for native Windows builds
- May need adaptation for cross-compilation
- Larger footprint than other options

**Status:**
Not recommended for cross-compilation use case.

## Recommendation

### For immediate use:
**Use the Fast Windows Build workflow** (`.github/workflows/build-windows-fast.yml`)
- It's production-ready
- First run takes ~2 hours but caches everything
- Subsequent runs: ~15 minutes
- Most reliable option

### For experimental ultra-fast builds:
**Try the new MSYS2 workflow** (`.github/workflows/build-windows-msys2.yml`)
- Uses pre-built packages from MSYS2
- Expected build time: ~10-15 minutes
- May need package URL updates over time
- Experimental status

### For future enhancement:
**Adapt Bitcoin Core's depends system**
- Would provide deterministic builds
- Perfect for cryptocurrency projects
- ~30-45 min initial build, ~5 min with cache
- Highest quality solution long-term

## Package Versions and URLs

### MSYS2 Current Packages (as of Dec 2025)

Base URL: `https://repo.msys2.org/mingw/mingw64/`

Common packages:
- Qt5: `mingw-w64-x86_64-qt5-base-*.pkg.tar.zst`
- Boost: `mingw-w64-x86_64-boost-*.pkg.tar.zst`
- OpenSSL: `mingw-w64-x86_64-openssl-*.pkg.tar.zst`
- BerkeleyDB: `mingw-w64-x86_64-db-*.pkg.tar.zst`
- miniupnpc: `mingw-w64-x86_64-miniupnpc-*.pkg.tar.zst`

**Note:** Package versions and filenames change. Visit the repository to find current versions.

### Bitcoin Core Depends

To use Bitcoin Core's depends system:

```bash
# Clone Bitcoin Core
git clone https://github.com/bitcoin/bitcoin.git
cd bitcoin/depends

# Build for Windows
make HOST=x86_64-w64-mingw32 -j$(nproc)

# Dependencies will be in: depends/x86_64-w64-mingw32/
# Can be copied and used for Trinity builds
```

## Quick Start Guide

### To try MSYS2 pre-built packages:

1. Go to Actions → "Ultra-Fast Windows Build (MSYS2 Dependencies)"
2. Click "Run workflow"
3. Wait ~10-15 minutes
4. Download artifacts

### To use the proven Fast Build:

1. Go to Actions → "Fast Windows Build with qmake"
2. Click "Run workflow"
3. First run: ~2 hours (caches MXE)
4. Subsequent runs: ~15 minutes
5. Download artifacts

## Contributing

If you successfully set up pre-built dependencies:
- Share the configuration
- Update package URLs if needed
- Report success/issues in GitHub Issues

## References

- MSYS2: https://www.msys2.org/
- Bitcoin depends: https://github.com/bitcoin/bitcoin/tree/master/depends
- MXE: https://mxe.cc/
- Vcpkg: https://vcpkg.io/

---

**Summary:** Multiple options exist for pre-built cross-compilation libraries. MSYS2 packages offer the quickest setup, while Bitcoin Core's depends system provides the best long-term solution for cryptocurrency projects.
