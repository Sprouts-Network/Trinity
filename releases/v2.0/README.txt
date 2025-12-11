Trinity Cryptocurrency Wallet v2.0.0 - Windows Release Package
===============================================================

CONTENTS:
---------
1. trinity-2.0.0-src.tar.gz     - Complete source code
2. build-windows-exe.sh         - Build script for Windows executable
3. BUILDING.txt                 - Detailed build instructions
4. README.txt                   - This file

QUICK START:
-----------
To build the Windows executable, you need a Linux system with:
- MinGW-w64 cross-compiler
- Qt 5.x for Windows (MinGW build)
- Boost libraries for Windows
- BerkeleyDB 4.8 for Windows
- OpenSSL for Windows

Then run: ./build-windows-exe.sh

ALTERNATIVE BUILD METHODS:
-------------------------
1. Use Docker (see BUILDING.txt)
2. Use GitHub Actions workflow
3. Build natively on Windows with Qt Creator

FEATURES IN v2.0:
----------------
- BIP39 seed phrase generation for secure wallet creation
- Mandatory seed phrase confirmation
- Dark/Light theme support
- Modern UI components
- Enhanced security and user experience

For detailed build instructions, see BUILDING.txt or visit:
https://github.com/Sprouts-Network/Trinity

LICENSE:
-------
MIT License - See COPYING in source package

SUPPORT:
-------
GitHub: https://github.com/Sprouts-Network/Trinity/issues
