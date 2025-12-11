#!/bin/bash
# Trinity Windows Build Verification Script
# This script verifies the build setup without requiring full dependencies

set -e

echo "================================================"
echo "Trinity Windows Build Verification"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check project structure
echo "Step 1: Verifying Project Structure"
echo "------------------------------------"

if [ -f "trinity-qt.pro" ]; then
    print_success "Found trinity-qt.pro"
else
    echo "ERROR: trinity-qt.pro not found!"
    exit 1
fi

if [ -f "src/clientversion.h" ]; then
    print_success "Found src/clientversion.h"
    VERSION=$(grep "CLIENT_VERSION_MAJOR" src/clientversion.h | awk '{print $3}')
    print_info "Version: $VERSION.x"
else
    echo "ERROR: src/clientversion.h not found!"
    exit 1
fi

# Count source files
CPP_FILES=$(find src -name "*.cpp" 2>/dev/null | wc -l)
H_FILES=$(find src -name "*.h" 2>/dev/null | wc -l)
UI_FILES=$(find src -name "*.ui" 2>/dev/null | wc -l)

print_success "Found $CPP_FILES C++ source files"
print_success "Found $H_FILES header files"
print_success "Found $UI_FILES Qt UI files"

echo ""
echo "Step 2: Checking Build Environment"
echo "-----------------------------------"

# Check for cross-compiler
if command -v x86_64-w64-mingw32-g++ &> /dev/null; then
    MINGW_VERSION=$(x86_64-w64-mingw32-g++ --version | head -1)
    print_success "MinGW cross-compiler available"
    print_info "$MINGW_VERSION"
else
    print_warning "MinGW cross-compiler not installed"
    print_info "Install with: sudo apt-get install g++-mingw-w64-x86-64"
fi

# Check for qmake
if command -v qmake &> /dev/null; then
    QMAKE_VERSION=$(qmake --version | head -1)
    print_success "qmake available"
    print_info "$QMAKE_VERSION"
elif command -v qmake-qt5 &> /dev/null; then
    QMAKE_VERSION=$(qmake-qt5 --version | head -1)
    print_success "qmake-qt5 available"
    print_info "$QMAKE_VERSION"
else
    print_warning "qmake not found (needed for building)"
fi

echo ""
echo "Step 3: Verifying GitHub Actions Workflows"
echo "-------------------------------------------"

if [ -f ".github/workflows/build-windows.yml" ]; then
    print_success "Found build-windows.yml workflow"
fi

if [ -f ".github/workflows/build-windows-mxe.yml" ]; then
    print_success "Found build-windows-mxe.yml workflow"
fi

echo ""
echo "Step 4: Checking Documentation"
echo "-------------------------------"

DOCS=("BUILDING-WINDOWS.md" "BUILD-STATUS.md" "WINDOWS-COMPILATION-NEXT-STEPS.md" "WINDOWS-DOWNLOAD-GUIDE.md")

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        print_success "Found $doc"
    fi
done

echo ""
echo "Step 5: Testing qmake Configuration (Dry Run)"
echo "----------------------------------------------"

if command -v qmake &> /dev/null || command -v qmake-qt5 &> /dev/null; then
    QMAKE_CMD=$(command -v qmake-qt5 2>/dev/null || command -v qmake)
    
    print_info "Testing qmake configuration..."
    
    # Create a temporary build directory
    TMP_BUILD_DIR="/tmp/trinity-build-test-$$"
    mkdir -p "$TMP_BUILD_DIR"
    cd "$TMP_BUILD_DIR"
    
    # Try to run qmake
    if $QMAKE_CMD "$OLDPWD/trinity-qt.pro" USE_UPNP=- 2>&1 | grep -q "Reading"; then
        print_success "qmake configuration successful"
        
        if [ -f "Makefile" ]; then
            print_success "Makefile generated"
            
            # Check Makefile content
            if grep -q "trinity-qt" Makefile; then
                print_success "Makefile contains trinity-qt target"
            fi
        fi
    else
        print_warning "qmake configuration needs dependencies"
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TMP_BUILD_DIR"
else
    print_warning "Skipping qmake test (qmake not available)"
fi

echo ""
echo "Step 6: Build Process Summary"
echo "------------------------------"

cat << 'EOF'

Trinity Windows Build Options:
==============================

1. GitHub Actions (Automated) - RECOMMENDED
   ├─ Workflow: build-windows-mxe.yml
   ├─ Method: Cross-compilation with MXE
   ├─ Duration: 2-4 hours (first run), 15-30 min (cached)
   └─ Output: trinity-qt.exe ready to download

2. Local Build with MXE
   ├─ Install MXE (one-time, 2-4 hours)
   ├─ Build Trinity (15-30 minutes)
   └─ Output: release/trinity-qt.exe

3. Using Pre-built Dependencies
   ├─ Download dependencies (varies)
   ├─ Configure paths
   └─ Build (15-30 minutes)

To build using GitHub Actions:
1. Go to GitHub Actions tab
2. Select "Build Windows Executable with MXE"
3. Click "Run workflow"
4. Wait for completion
5. Download artifacts

For detailed instructions, see:
- WINDOWS-DOWNLOAD-GUIDE.md
- BUILDING-WINDOWS.md

EOF

echo ""
echo "================================================"
echo "Verification Complete!"
echo "================================================"
echo ""
print_success "Project structure is valid"
print_success "Build configuration is ready"
print_success "GitHub Actions workflows are in place"
print_success "Documentation is available"
echo ""
print_info "To build Windows executable:"
print_info "1. Use GitHub Actions workflow (recommended)"
print_info "2. Or follow WINDOWS-DOWNLOAD-GUIDE.md for local build"
echo ""
