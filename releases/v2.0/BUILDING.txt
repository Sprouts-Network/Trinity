# Building Trinity for Windows

This document explains how to build Trinity v2.0 for Windows.

## Quick Summary

Building Trinity for Windows requires cross-compiled dependencies. Due to the complexity of building all dependencies from scratch (Qt, Boost, BerkeleyDB, OpenSSL, etc.), we provide several approaches:

1. **Using Pre-built Dependencies** (Recommended)
2. **Using Docker** (Automated)
3. **Using Gitian** (Deterministic Builds)
4. **Manual Cross-Compilation** (Advanced)

## Option 1: Using Pre-built Dependencies (Recommended)

### Prerequisites
- Linux system (Ubuntu 20.04+ recommended)
- MinGW-w64 cross-compiler
- Pre-built Windows dependencies

### Install Cross-Compiler
```bash
sudo apt-get update
sudo apt-get install g++-mingw-w64-x86-64 mingw-w64-x86-64-dev
```

### Download Pre-built Dependencies
You need Windows builds of:
- Qt 5.x for MinGW 64-bit
- Boost 1.50+ for MinGW
- BerkeleyDB 4.8.30 for MinGW
- OpenSSL 1.0.x for MinGW
- miniupnpc for MinGW

Extract these to a dependencies folder, e.g., `/home/user/deps-win/`

### Build Trinity
```bash
# Configure paths to your dependencies
export BOOST_INCLUDE=/path/to/boost/include
export BOOST_LIB=/path/to/boost/lib
export BDB_INCLUDE=/path/to/db/include
export BDB_LIB=/path/to/db/lib
export OPENSSL_INCLUDE=/path/to/openssl/include
export OPENSSL_LIB=/path/to/openssl/lib
export QT_PATH=/path/to/qt/mingw64

# Run qmake with cross-compilation settings
$QT_PATH/bin/qmake \
  BOOST_INCLUDE_PATH=$BOOST_INCLUDE \
  BOOST_LIB_PATH=$BOOST_LIB \
  BDB_INCLUDE_PATH=$BDB_INCLUDE \
  BDB_LIB_PATH=$BDB_LIB \
  OPENSSL_INCLUDE_PATH=$OPENSSL_INCLUDE \
  OPENSSL_LIB_PATH=$OPENSSL_LIB \
  BOOST_LIB_SUFFIX=-mgw-mt-s-1_50 \
  trinity-qt.pro

# Build
make -j$(nproc)

# The executable will be in the release/ directory
x86_64-w64-mingw32-strip release/trinity-qt.exe
```

## Option 2: Using Docker

A Dockerfile is provided for a consistent build environment:

```bash
# Build the Docker image
docker build -f Dockerfile.windows -t trinity-windows-builder .

# Run the container
docker run -v $(pwd):/trinity -it trinity-windows-builder

# Inside the container, after setting up dependencies:
cd /trinity
# Run build commands as described in Option 1
```

## Option 3: Using GitHub Actions

A GitHub Actions workflow is provided in `.github/workflows/build-windows.yml` that:
- Sets up the cross-compilation environment
- Downloads dependencies
- Builds the Windows executable
- Creates a release with the binary

Trigger it by:
- Pushing a version tag (e.g., `git tag v2.0 && git push origin v2.0`)
- Manual workflow dispatch from GitHub Actions UI

## Option 4: Manual Dependency Compilation

If you want to build all dependencies from scratch:

### 1. Build Boost for Windows
```bash
cd /tmp
wget https://sourceforge.net/projects/boost/files/boost/1.50.0/boost_1_50_0.tar.bz2
tar xjf boost_1_50_0.tar.bz2
cd boost_1_50_0
./bootstrap.sh
echo "using gcc : mingw : x86_64-w64-mingw32-g++ ;" > user-config.jam
./b2 toolset=gcc-mingw target-os=windows variant=release \
  threading=multi link=static runtime-link=static \
  --with-system --with-filesystem --with-thread \
  --with-program_options --with-chrono
```

### 2. Build BerkeleyDB for Windows
```bash
cd /tmp
wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz
tar xzf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix
../dist/configure --enable-mingw --enable-cxx \
  --host=x86_64-w64-mingw32 --prefix=/usr/x86_64-w64-mingw32
make
sudo make install
```

### 3. Build OpenSSL for Windows
```bash
cd /tmp
wget https://www.openssl.org/source/openssl-1.0.1c.tar.gz
tar xzf openssl-1.0.1c.tar.gz
cd openssl-1.0.1c
./Configure mingw64 --cross-compile-prefix=x86_64-w64-mingw32- \
  --prefix=/usr/x86_64-w64-mingw32
make
sudo make install
```

### 4. Build Qt for Windows
This is the most complex dependency. It's recommended to use pre-built Qt for MinGW from the Qt website:
https://www.qt.io/download-open-source

### 5. Build miniupnpc for Windows
```bash
cd /tmp
wget http://miniupnp.free.fr/files/miniupnpc-1.6.tar.gz
tar xzf miniupnpc-1.6.tar.gz
cd miniupnpc-1.6
make -f Makefile.mingw \
  CC=x86_64-w64-mingw32-gcc \
  AR=x86_64-w64-mingw32-ar
```

## Simplified Build Script

Use the provided build script:

```bash
chmod +x build-windows.sh
./build-windows.sh
```

This script will:
1. Install the MinGW cross-compiler
2. Set up the build environment
3. Provide instructions for downloading dependencies

## What's New in v2.0

This release includes:
- Modern wallet creation dialog with BIP39 seed phrase support
- Dark/Light theme support
- Updated UI components
- Version bumped to 2.0.0
- Copyright year updated to 2025

## Verifying the Build

After building, verify the executable:

```bash
file release/trinity-qt.exe
# Should output: PE32+ executable (GUI) x86-64, for MS Windows

# Test on Windows or with Wine
wine release/trinity-qt.exe
```

## Troubleshooting

### Missing dependencies
Ensure all dependency paths are correctly set in the qmake command.

### Linker errors
Check that library paths point to Windows (MinGW) builds, not Linux builds.

### Qt plugin errors
Make sure Qt plugins are built for Windows and deployed with the executable.

## Support

For build issues, please open an issue on GitHub:
https://github.com/Sprouts-Network/Trinity/issues

## License

Trinity is released under the MIT license. See COPYING for details.
