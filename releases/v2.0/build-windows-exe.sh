#!/bin/bash
# Trinity v2.0 Windows Executable Build Script
# This script should be run on a system with Windows cross-compilation dependencies

set -e

TRINITY_SRC="${TRINITY_SRC:-.}"
QT_WIN="${QT_WIN:-/usr/x86_64-w64-mingw32/qt5}"
BOOST_ROOT="${BOOST_ROOT:-/usr/x86_64-w64-mingw32}"
BDB_ROOT="${BDB_ROOT:-/usr/x86_64-w64-mingw32}"
OPENSSL_ROOT="${OPENSSL_ROOT:-/usr/x86_64-w64-mingw32}"

echo "Building Trinity for Windows..."
echo "Source: $TRINITY_SRC"

cd "$TRINITY_SRC"

# Build leveldb
echo "Building leveldb..."
cd src/leveldb
TARGET_OS=OS_WINDOWS_CROSSCOMPILE make libleveldb.a libmemenv.a \
    CC=x86_64-w64-mingw32-gcc \
    CXX=x86_64-w64-mingw32-g++
cd ../..

# Run qmake
echo "Running qmake..."
x86_64-w64-mingw32-qmake-qt5 \
    BOOST_INCLUDE_PATH="$BOOST_ROOT/include" \
    BOOST_LIB_PATH="$BOOST_ROOT/lib" \
    BDB_INCLUDE_PATH="$BDB_ROOT/include" \
    BDB_LIB_PATH="$BDB_ROOT/lib" \
    OPENSSL_INCLUDE_PATH="$OPENSSL_ROOT/include" \
    OPENSSL_LIB_PATH="$OPENSSL_ROOT/lib" \
    USE_UPNP=- \
    trinity-qt.pro || echo "Note: qmake may need adjustments for your environment"

# Build
echo "Building..."
make -j$(nproc) || echo "Build may require dependency adjustments"

echo "If successful, executable is at: release/trinity-qt.exe"
