# Windows Executable Compilation and Download Guide

This guide explains how to compile and download the Trinity Windows executable using the automated GitHub Actions workflows.

## Overview

Trinity v2.0 includes two GitHub Actions workflows for Windows compilation:

1. **`build-windows.yml`** - Quick documentation and verification workflow
2. **`build-windows-mxe.yml`** - Full Windows executable build using MXE

## Quick Start: Download Pre-built Windows Executable

### Option 1: Download from GitHub Actions Artifacts

1. Navigate to the [Actions tab](https://github.com/Sprouts-Network/Trinity/actions)
2. Click on the "Build Windows Executable with MXE" workflow
3. Click "Run workflow" button
4. Wait for the build to complete (2-4 hours first time, ~15 minutes with cache)
5. Download the artifacts:
   - `trinity-windows-x64-executable` - Contains trinity-qt.exe
   - `trinity-windows-x64-package` - Contains ZIP package with exe and docs

### Option 2: Download from GitHub Releases

1. Go to [Releases page](https://github.com/Sprouts-Network/Trinity/releases)
2. Find the latest v2.0 release
3. Download `trinity-qt.exe` or the ZIP package
4. Run on your Windows system

## Building Windows Executable

### Method 1: Using GitHub Actions (Recommended)

The easiest way to build Trinity for Windows is using GitHub Actions:

**Step 1: Trigger the MXE Build Workflow**

```bash
# From your local repository
git push origin main
```

Or manually trigger from GitHub:
1. Go to Actions tab
2. Select "Build Windows Executable with MXE"
3. Click "Run workflow"
4. Wait for completion

**Step 2: Download the Executable**

Once the workflow completes:
1. Click on the completed workflow run
2. Scroll to "Artifacts" section at the bottom
3. Download `trinity-windows-x64-package.zip`
4. Extract and run trinity-qt.exe

**Build Time:**
- First build: 2-4 hours (builds MXE dependencies)
- Subsequent builds: 15-30 minutes (uses cached dependencies)

### Method 2: Using MXE Locally

To build locally with MXE:

```bash
# 1. Install MXE (one-time setup, takes 2-4 hours)
cd /opt
sudo git clone https://github.com/mxe/mxe.git
cd mxe
sudo make MXE_TARGETS='x86_64-w64-mingw32.static' \
  qtbase qttools boost db openssl miniupnpc -j$(nproc)

# 2. Build Trinity
cd /path/to/Trinity
export PATH=/opt/mxe/usr/bin:$PATH
x86_64-w64-mingw32.static-qmake-qt5 trinity-qt.pro
make -j$(nproc)

# 3. Executable will be at: release/trinity-qt.exe
```

### Method 3: Using Pre-built Dependencies

If you have pre-built Windows dependencies:

```bash
# Set paths to your dependencies
export QT_WIN=/path/to/qt-windows
export BOOST_WIN=/path/to/boost-windows
export BDB_WIN=/path/to/berkeleydb-windows
export OPENSSL_WIN=/path/to/openssl-windows

# Configure and build
$QT_WIN/bin/qmake \
  BOOST_INCLUDE_PATH=$BOOST_WIN/include \
  BOOST_LIB_PATH=$BOOST_WIN/lib \
  BDB_INCLUDE_PATH=$BDB_WIN/include \
  BDB_LIB_PATH=$BDB_WIN/lib \
  OPENSSL_INCLUDE_PATH=$OPENSSL_WIN/include \
  OPENSSL_LIB_PATH=$OPENSSL_WIN/lib \
  trinity-qt.pro

make -j$(nproc)
```

## Verifying the Windows Build

After building, verify the executable:

```bash
# Check file type
file release/trinity-qt.exe
# Should output: PE32+ executable (GUI) x86-64, for MS Windows

# Check size
ls -lh release/trinity-qt.exe
# Should be several MB (static build)

# Test with Wine (on Linux)
wine release/trinity-qt.exe --version
```

## Running Trinity on Windows

1. **Download** the executable from GitHub Actions or Releases
2. **Extract** if downloaded as ZIP
3. **Run** trinity-qt.exe
4. **Create wallet** using the modern onboarding flow
5. **Backup** your seed phrase securely!

## Workflow Details

### build-windows.yml

- **Purpose**: Quick verification and documentation
- **Runs on**: Push to tags (v*) or manual trigger
- **Duration**: ~5 minutes
- **Output**: Build documentation and guides
- **Use when**: You want documentation without full build

### build-windows-mxe.yml

- **Purpose**: Complete Windows executable compilation
- **Runs on**: Manual trigger only
- **Duration**: 2-4 hours (first run), 15-30 min (cached)
- **Output**: trinity-qt.exe and distribution package
- **Use when**: You need a working Windows executable

## Troubleshooting

### Build Fails at MXE Setup

- **Issue**: MXE compilation timeout
- **Solution**: Run workflow again, it will use cached progress

### Can't Find Executable

- **Issue**: Workflow completed but no .exe in artifacts
- **Solution**: Check workflow logs for errors in "Build Trinity for Windows" step

### Executable Won't Run on Windows

- **Issue**: "Missing DLL" or similar errors
- **Solution**: Use the MXE workflow which creates static builds

### Build Takes Too Long

- **Issue**: First MXE build takes 2-4 hours
- **Solution**: This is normal. Subsequent builds use cache and are much faster

## Advanced: Caching and Optimization

The MXE workflow uses GitHub Actions cache to speed up builds:

```yaml
- name: Cache MXE build
  uses: actions/cache@v3
  with:
    path: /opt/mxe
    key: mxe-x86-64-static-qt5-minimal-v2
```

This cache:
- Saves ~2-3 hours on subsequent builds
- Stores compiled MXE dependencies
- Is shared across workflow runs
- Automatically invalidates when key changes

## Release Process

To create an official release with Windows executable:

```bash
# 1. Create and push tag
git tag v2.0.1
git push origin v2.0.1

# 2. This triggers build-windows.yml automatically

# 3. Manually trigger build-windows-mxe.yml from GitHub

# 4. Wait for both workflows to complete

# 5. Download executable from MXE workflow artifacts

# 6. Manually upload to GitHub Release page
```

## System Requirements

**For Building:**
- Linux system (Ubuntu 20.04+ recommended)
- 8GB RAM minimum
- 20GB free disk space
- Internet connection for downloading dependencies

**For Running (Windows):**
- Windows 7 or later
- 64-bit Windows
- 2GB RAM minimum
- 500MB disk space

## Features in Trinity v2.0

The Windows executable includes all v2.0 features:

- ✨ Modern wallet creation with BIP39 seed phrase
- 🎨 Dark/Light theme support
- 🔐 Enhanced security features
- 💎 Modernized UI components
- 📱 Responsive interface

## Support

- **Issues**: https://github.com/Sprouts-Network/Trinity/issues
- **Documentation**: See repository docs/
- **Source Code**: https://github.com/Sprouts-Network/Trinity

## License

Trinity is released under the MIT License. See [COPYING](../COPYING) for details.

---

**Last Updated**: December 2024
**Trinity Version**: 2.0
