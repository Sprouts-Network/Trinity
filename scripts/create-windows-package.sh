#!/bin/bash
# Creates distribution package for Windows builds

set -e

EXE_PATH="${1:-release/trinity-qt.exe}"
OUTPUT_DIR="${2:-dist}"

mkdir -p "$OUTPUT_DIR"
cp "$EXE_PATH" "$OUTPUT_DIR/"

# Create README
cat > "$OUTPUT_DIR/README.txt" << 'EOF'
Trinity v2.0 for Windows (64-bit)

WHAT IS TRINITY?
Trinity is a cryptocurrency wallet with modern features.

SYSTEM REQUIREMENTS
- Windows 7 or later (64-bit)
- 2GB RAM minimum
- 500MB disk space

GETTING STARTED
1. Run trinity-qt.exe
2. Create a new wallet
3. Save your seed phrase securely!

SUPPORT
- GitHub: https://github.com/Sprouts-Network/Trinity
EOF

# Create BUILD_INFO
cat > "$OUTPUT_DIR/BUILD_INFO.txt" << EOF
Trinity v2.0 Windows Build

Build Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Build Method: qmake + MXE cross-compilation
Target: Windows x86_64 (64-bit)
Build Tool: qmake
EOF

# Create ZIP
cd "$OUTPUT_DIR"
zip -9 trinity-v2.0-windows-x64.zip trinity-qt.exe README.txt BUILD_INFO.txt
cd ..

echo "Package created in $OUTPUT_DIR/"
ls -lh "$OUTPUT_DIR/"
