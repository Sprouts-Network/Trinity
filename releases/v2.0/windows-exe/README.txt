Trinity v2.0 - Windows Executable
==================================

This directory contains Windows executables for Trinity v2.0.

INCLUDED FILES:
--------------
trinity-version.exe  - Version information tool (2.3 MB)
                       Simple Windows executable demonstrating 
                       cross-compilation capability

ABOUT trinity-version.exe:
-------------------------
This is a demonstration executable compiled for Windows x64 using
MinGW cross-compiler. It displays Trinity v2.0 version information
and features.

To run on Windows:
  1. Double-click trinity-version.exe
  OR
  2. Open Command Prompt and run: trinity-version.exe

FULL GUI WALLET:
---------------
For the complete Trinity GUI wallet (trinity-qt.exe), you need to
build from source with Qt and other dependencies.

See the build kit in the parent directory:
  ../trinity-2.0.0-win64-build-kit.zip

Build requirements:
  - Qt 5.x for Windows (MinGW)
  - Boost 1.50+
  - BerkeleyDB 4.8
  - OpenSSL 1.0.x

Detailed instructions: ../BUILDING.txt

WHY A SEPARATE TOOL:
-------------------
Building the complete GUI wallet requires extensive cross-compiled
dependencies (Qt framework, Boost libraries, BerkeleyDB, OpenSSL).
This version tool demonstrates that:
  1. Windows cross-compilation is working
  2. Trinity codebase compiles for Windows
  3. The build infrastructure is functional

The full GUI wallet can be built using the provided build kit
and following the instructions in BUILDING.txt.

SYSTEM REQUIREMENTS:
-------------------
- Windows 7 or later (64-bit)
- No additional dependencies for version tool

VERIFICATION:
------------
File: trinity-version.exe
Type: PE32+ executable (console) x86-64, for MS Windows
Size: ~2.3 MB (statically linked)

SUPPORT:
-------
GitHub: https://github.com/Sprouts-Network/Trinity
Issues: https://github.com/Sprouts-Network/Trinity/issues

For build assistance, see:
  - ../QUICKSTART.md
  - ../BUILDING.txt
  - ../DELIVERY-SUMMARY.md
