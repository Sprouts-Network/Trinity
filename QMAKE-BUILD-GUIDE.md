# Trinity Windows Build Options - Quick Reference

This document explains all available methods for building Trinity for Windows using qmake.

## 🎯 TL;DR - Which Method Should I Use?

| Your Situation | Recommended Method | Expected Time |
|----------------|-------------------|---------------|
| First time building | Fast Windows Build (with cache) | ~2 hours first run, 15 min after |
| Regular CI/CD builds | Fast Windows Build | ~15 minutes |
| Have pre-built deps | Ultra-Fast Build | ~5-10 minutes |
| Want full control | Manual qmake build | Varies |
| Need deterministic builds | MXE with full build | ~2-4 hours |

## 📋 Available Build Methods

### 1. Fast Windows Build (Recommended) ⭐

**Workflow:** `.github/workflows/build-windows-fast.yml`

**How it works:**
- Uses MXE (M cross environment) to cross-compile
- Aggressively caches the entire MXE toolchain
- First run builds everything, subsequent runs use cache
- Builds with qmake automatically

**Time:**
- First run: ~2 hours (one-time setup)
- Subsequent runs: ~15 minutes

**Pros:**
- ✅ Reliable and tested
- ✅ Complete build environment
- ✅ Works out of the box
- ✅ Uses qmake as primary build tool

**Cons:**
- ⏱️ First run takes time
- 💾 Requires cache storage

**How to use:**
```bash
# Via GitHub Actions
1. Go to Actions tab
2. Select "Fast Windows Build with qmake"
3. Click "Run workflow"

# Locally (after setting up MXE)
./build-windows-qmake.sh
```

### 2. Ultra-Fast Build (Pre-built Dependencies) ⚡

**Workflow:** `.github/workflows/build-windows-ultra-fast.yml`

**How it works:**
- Uses pre-built Windows dependencies
- Only compiles Trinity source code
- Skips dependency compilation entirely

**Time:**
- ~5-10 minutes (once dependencies are available)

**Pros:**
- ⚡ Extremely fast builds
- 🎯 Perfect for rapid development
- 💾 Minimal cache usage

**Cons:**
- 📦 Requires pre-built dependencies
- 🔧 Initial setup needed

**Status:** Ready to use once dependencies are provided

**How to set up:**
See `ULTRA_FAST_BUILD_INFO.txt` for detailed instructions

### 3. Original MXE Build (Full Build)

**Workflow:** `.github/workflows/build-windows-mxe.yml`

**How it works:**
- Builds MXE and all dependencies from scratch
- Manual workflow dispatch only
- Most thorough but slowest approach

**Time:**
- ~2-4 hours per build

**Pros:**
- ✅ Complete rebuild every time
- ✅ No dependency on cache
- ✅ Reproducible

**Cons:**
- ⏱️ Very slow
- 🔄 Rebuilds everything each time

**When to use:**
- Verifying clean builds
- Creating official releases
- Debugging build issues

### 4. Manual Local Build

**Script:** `build-windows-qmake.sh`

**How it works:**
- Run qmake and make on your local machine
- Requires pre-installed MXE or Windows build environment

**Time:**
- Varies based on your setup
- ~15-30 minutes with MXE ready

**How to use:**
```bash
# Install MXE (one-time)
sudo mkdir -p /opt/mxe
sudo chown $(whoami) /opt/mxe
git clone https://github.com/mxe/mxe.git /opt/mxe
cd /opt/mxe
make MXE_TARGETS='x86_64-w64-mingw32.static' qtbase qttools boost db openssl miniupnpc

# Build Trinity
cd /path/to/Trinity
./build-windows-qmake.sh
```

## 🔧 Using qmake Directly

All methods use qmake as the build configuration tool. Here's how qmake is used:

### Basic qmake Command

```bash
qmake \
  USE_UPNP=1 \
  USE_QRCODE=0 \
  RELEASE=1 \
  trinity-qt.pro
```

### With Custom Dependencies

```bash
qmake \
  BOOST_INCLUDE_PATH=/path/to/boost/include \
  BOOST_LIB_PATH=/path/to/boost/lib \
  BDB_INCLUDE_PATH=/path/to/db/include \
  BDB_LIB_PATH=/path/to/db/lib \
  OPENSSL_INCLUDE_PATH=/path/to/openssl/include \
  OPENSSL_LIB_PATH=/path/to/openssl/lib \
  USE_UPNP=1 \
  RELEASE=1 \
  trinity-qt.pro

make -j$(nproc)
```

### qmake Configuration Variables

The `trinity-qt.pro` file supports these qmake variables:

- `BOOST_INCLUDE_PATH` - Path to Boost headers
- `BOOST_LIB_PATH` - Path to Boost libraries
- `BOOST_LIB_SUFFIX` - Boost library suffix (e.g., -mt-s-1_50)
- `BDB_INCLUDE_PATH` - Path to BerkeleyDB headers
- `BDB_LIB_PATH` - Path to BerkeleyDB libraries
- `BDB_LIB_SUFFIX` - BerkeleyDB library suffix
- `OPENSSL_INCLUDE_PATH` - Path to OpenSSL headers
- `OPENSSL_LIB_PATH` - Path to OpenSSL libraries
- `MINIUPNPC_INCLUDE_PATH` - Path to miniupnpc headers
- `MINIUPNPC_LIB_PATH` - Path to miniupnpc libraries
- `USE_UPNP` - Enable UPnP support (1, 0, or -)
- `USE_QRCODE` - Enable QR code support (1 or 0)
- `RELEASE` - Build release version (1)
- `USE_IPV6` - Enable IPv6 support (1, 0, or -)

## 📊 Performance Comparison

| Method | First Build | Subsequent | Cache Size | Reliability |
|--------|-------------|------------|------------|-------------|
| Fast Build (MXE cache) | 2 hours | 15 min | ~3-5 GB | ⭐⭐⭐⭐⭐ |
| Ultra-Fast (pre-built) | 10 min | 5 min | ~1 GB | ⭐⭐⭐⭐ |
| Full MXE Build | 2-4 hours | 2-4 hours | None | ⭐⭐⭐⭐⭐ |
| Manual Local | 30 min | 15 min | Local | ⭐⭐⭐⭐ |

## 🎓 Understanding the Build Process

### What qmake Does

1. **Reads** `trinity-qt.pro` project file
2. **Generates** platform-specific Makefile
3. **Configures** compiler flags, include paths, libraries
4. **Sets up** build rules for Qt MOC, UI files, resources

### What make Does

1. **Compiles** C++ source files
2. **Processes** Qt UI files (forms/*.ui)
3. **Runs** Qt MOC (Meta-Object Compiler) on headers
4. **Links** libraries and creates executable
5. **Builds** leveldb dependency

### Why Use qmake?

- ✅ Native Qt build system
- ✅ Cross-platform project files
- ✅ Automatic Qt integration (MOC, UIC, RCC)
- ✅ Simple, declarative configuration
- ✅ Well-documented and widely used

## 🚀 Getting Started

### Quick Start with GitHub Actions (Recommended)

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Select **"Fast Windows Build with qmake"**
4. Click **"Run workflow"** button
5. Wait ~2 hours for first build (or ~15 min if cached)
6. Download artifact from workflow run

### Quick Start Locally

```bash
# Clone the repository
git clone https://github.com/Sprouts-Network/Trinity.git
cd Trinity

# Use the fast build script (requires MXE)
./build-windows-qmake.sh

# Or configure manually with qmake
# (requires pre-installed dependencies)
qmake USE_UPNP=1 RELEASE=1 trinity-qt.pro
make -j$(nproc)
```

## 📦 Build Output

All successful builds produce:

- `release/trinity-qt.exe` - Windows executable
- Static linking - no DLL dependencies needed
- Size: ~15-25 MB (before stripping), ~8-12 MB (after stripping)
- Target: Windows 7+ (64-bit)

## 🔍 Troubleshooting

### Build fails with "qmake: command not found"

**Solution:** Install Qt or MXE which provides qmake for cross-compilation

### Linker errors about missing libraries

**Solution:** Check that all dependency paths are correctly set in qmake command

### "Makefile not found" error

**Solution:** Run qmake first to generate Makefile

### Build takes too long

**Solution:** 
- Use the Fast Build workflow with caching
- Or use make with -j flag: `make -j$(nproc)`

## 📚 Additional Resources

- [Full Windows Build Guide](BUILDING-WINDOWS.md)
- [Windows Download Guide](WINDOWS-DOWNLOAD-GUIDE.md)
- [MXE Documentation](https://mxe.cc/)
- [Qt qmake Documentation](https://doc.qt.io/qt-5/qmake-manual.html)

## 💡 Pro Tips

1. **Use the Fast Build workflow** - It's optimized and tested
2. **Enable caching** - Saves hours on subsequent builds
3. **Build locally only if needed** - GitHub Actions is easier
4. **Keep MXE cached** - Don't rebuild dependencies unnecessarily
5. **Use workflow_dispatch** - Manually trigger builds when needed

## 🆘 Need Help?

- Check [Issues](https://github.com/Sprouts-Network/Trinity/issues)
- Review [Build Documentation](BUILDING-WINDOWS.md)
- See workflow files in `.github/workflows/`

---

**Trinity Version:** 2.0
