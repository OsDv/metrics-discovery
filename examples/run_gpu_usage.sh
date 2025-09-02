#!/bin/bash
#
# Run script for GPU Usage Monitor
# 
# This script sets up the environment and runs the gpu_usage program
# with the correct library path for the Intel Metrics Discovery library.

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Set library path
LIB_PATH="$PROJECT_ROOT/dump/linux64/release/metrics_discovery"
export LD_LIBRARY_PATH="$LIB_PATH:$LD_LIBRARY_PATH"

# Check if library exists
if [ ! -f "$LIB_PATH/libigdmd.so" ]; then
    echo "Error: Intel Metrics Discovery library not found at: $LIB_PATH/libigdmd.so"
    echo "Please build the library first:"
    echo "  cd $PROJECT_ROOT"
    echo "  mkdir -p build && cd build"
    echo "  cmake .. && make"
    exit 1
fi

# Check if program exists
if [ ! -f "$SCRIPT_DIR/gpu_usage" ]; then
    echo "Error: gpu_usage program not found at: $SCRIPT_DIR/gpu_usage"
    echo "Please build the program first:"
    echo "  cd $SCRIPT_DIR"
    echo "  make"
    exit 1
fi

# Run the program with provided arguments
echo "Running GPU Usage Monitor..."
echo "Library path: $LIB_PATH"
echo "----------------------------------------"
exec "$SCRIPT_DIR/gpu_usage" "$@"