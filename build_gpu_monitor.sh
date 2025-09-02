#!/bin/bash
#
# Build Script for Intel GPU Usage Monitor
#
# This script automates the build process for both the Intel Metrics Discovery 
# library and the GPU Usage Monitor program.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Get project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="$PROJECT_ROOT/examples"

log_info "Building Intel GPU Usage Monitor"
log_info "Project root: $PROJECT_ROOT"

# Check if we're in the right directory
if [ ! -f "$PROJECT_ROOT/CMakeLists.txt" ]; then
    log_error "This script must be run from the metrics-discovery repository"
    log_error "Expected to find CMakeLists.txt in: $PROJECT_ROOT"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
log_info "Checking build dependencies..."

if ! command_exists cmake; then
    log_error "CMake is required but not installed"
    log_info "Install with: sudo apt install cmake (Ubuntu/Debian) or sudo dnf install cmake (Fedora/RHEL)"
    exit 1
fi

if ! command_exists make; then
    log_error "Make is required but not installed"
    log_info "Install with: sudo apt install build-essential (Ubuntu/Debian)"
    exit 1
fi

if ! command_exists gcc; then
    log_error "GCC is required but not installed"
    log_info "Install with: sudo apt install build-essential (Ubuntu/Debian)"
    exit 1
fi

if ! command_exists g++; then
    log_error "G++ is required but not installed"
    log_info "Install with: sudo apt install build-essential (Ubuntu/Debian)"
    exit 1
fi

# Check for libdrm-dev
if ! pkg-config --exists libdrm 2>/dev/null; then
    log_error "libdrm-dev is required but not installed"
    log_info "Install with: sudo apt install libdrm-dev (Ubuntu/Debian) or sudo dnf install libdrm-devel (Fedora/RHEL)"
    exit 1
fi

log_success "All dependencies satisfied"

# Build the Intel Metrics Discovery library
log_info "Building Intel Metrics Discovery library..."

BUILD_DIR="$PROJECT_ROOT/build"
LIB_DIR="$PROJECT_ROOT/dump/linux64/release/metrics_discovery"

# Create build directory
if [ -d "$BUILD_DIR" ]; then
    log_info "Cleaning existing build directory..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure with CMake
log_info "Configuring with CMake..."
cmake .. || {
    log_error "CMake configuration failed"
    exit 1
}

# Build the library
log_info "Building library (this may take several minutes)..."
make -j$(nproc) || {
    log_error "Library build failed"
    exit 1
}

# Verify library was built
if [ ! -f "$LIB_DIR/libigdmd.so" ]; then
    log_error "Library build failed - libigdmd.so not found"
    exit 1
fi

log_success "Intel Metrics Discovery library built successfully"
log_info "Library location: $LIB_DIR/libigdmd.so"

# Build the GPU Usage Monitor
log_info "Building GPU Usage Monitor..."

cd "$EXAMPLES_DIR"

# Check requirements
make check || {
    log_error "GPU Usage Monitor requirements check failed"
    exit 1
}

# Clean and build
make clean
make || {
    log_error "GPU Usage Monitor build failed"
    exit 1
}

# Verify program was built
if [ ! -f "$EXAMPLES_DIR/gpu_usage" ]; then
    log_error "GPU Usage Monitor build failed - gpu_usage not found"
    exit 1
fi

log_success "GPU Usage Monitor built successfully"
log_info "Program location: $EXAMPLES_DIR/gpu_usage"

# Test the program
log_info "Testing the program..."
cd "$EXAMPLES_DIR"
./gpu_usage --help >/dev/null || {
    log_error "Program test failed"
    exit 1
}

log_success "Program test passed"

# Print usage instructions
echo
log_success "Build completed successfully!"
echo
log_info "Usage:"
echo "  cd $EXAMPLES_DIR"
echo "  ./run_gpu_usage.sh --help      # Show help"
echo "  ./run_gpu_usage.sh --snapshot  # Single snapshot"
echo "  ./run_gpu_usage.sh             # Continuous monitoring"
echo
log_info "Direct usage (requires setting LD_LIBRARY_PATH):"
echo "  export LD_LIBRARY_PATH=$LIB_DIR:\$LD_LIBRARY_PATH"
echo "  ./gpu_usage --snapshot"
echo
log_warn "Note: This program requires an Intel GPU and appropriate permissions."
log_warn "      Run with sudo if you encounter access denied errors."