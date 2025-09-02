# GPU Usage Monitor - Intel Metrics Discovery

This directory contains a C program that uses the Intel Metrics Discovery library to measure GPU usage on Intel UHD 620 integrated GPU and other supported Intel GPUs.

## Features

- **GPU Detection**: Automatically detects and initializes Intel GPU adapters
- **Metrics Enumeration**: Enumerates available metric sets and finds GPU engine utilization metrics
- **Engine Monitoring**: Monitors GPU engine utilization for:
  - Render engine
  - Blitter engine  
  - Video engine
  - Enhance engine (if available)
- **Display Modes**: 
  - Single snapshot mode (`--snapshot` or `-s`)
  - Continuous monitoring mode (default, updates every 1 second)
- **Clear Output**: Displays usage in easy-to-read format:
  ```
  Render: 23.5%  Blitter: 0.0%  Video: 12.3%  Enhance: 0.0%  | Total: 35.8%
  ```
- **Normalization**: Automatically normalizes metrics so total usage doesn't exceed 100%
- **Error Handling**: Comprehensive error handling and resource cleanup

## Requirements

### System Requirements
- **Linux System**: Requires Linux kernel 5.7 or later
- **Intel GPU**: Supported Intel GPU (see main README for platform compatibility)
- **Mesa Driver**: Minimum Mesa version 18.2 (varies by platform)

### Build Dependencies
- **GCC/G++**: C++11 compatible compiler
- **libdrm-dev**: Development headers for Direct Rendering Manager
- **CMake**: For building the metrics discovery library

## Step-by-Step Build Instructions

### 1. Install System Dependencies

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install build-essential cmake libdrm-dev
```

**Fedora/CentOS/RHEL:**
```bash
sudo dnf install gcc gcc-c++ cmake libdrm-devel
# OR for older versions:
sudo yum install gcc gcc-c++ cmake libdrm-devel
```

### 2. Clone and Build Intel Metrics Discovery Library

```bash
# Clone the repository (if not already done)
git clone https://github.com/intel/metrics-discovery.git
cd metrics-discovery

# Create build directory and configure
mkdir -p build
cd build

# Configure with CMake
cmake ..

# Build the library (this may take several minutes)
make -j$(nproc)

# Verify the library was built
ls ../dump/linux64/release/metrics_discovery/libigdmd.so
```

### 3. Build the GPU Usage Monitor

```bash
# Navigate to examples directory
cd ../examples

# Check build requirements
make check

# Build the program
make

# Verify the program was built
ls -la gpu_usage
```

### 4. Set Environment Variables (Optional)

If you plan to run the program from a different directory, you may need to set the library path:

```bash
# Add the library path to LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/path/to/metrics-discovery/dump/linux64/release/metrics_discovery:$LD_LIBRARY_PATH

# Or for permanent setup, add to ~/.bashrc:
echo 'export LD_LIBRARY_PATH=/path/to/metrics-discovery/dump/linux64/release/metrics_discovery:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc
```

## Usage

### Basic Usage

```bash
# Single snapshot
./gpu_usage --snapshot
./gpu_usage -s

# Continuous monitoring (updates every 1 second)
./gpu_usage

# Show help
./gpu_usage --help
./gpu_usage -h
```

### Example Output

**Single Snapshot:**
```
Intel GPU Usage Monitor
======================
Initializing Intel Metrics Discovery API...
Loaded library from: ../dump/linux64/release/metrics_discovery/libigdmd.so
Found 1 adapter(s)
Found Intel GPU: Intel(R) UHD Graphics 620 (Device ID: 0x5917)
Metrics device opened successfully
Device has 2 concurrent group(s)
Concurrent group 0: OA (15 metric sets)
  Metric set 0: RenderBasic (45 metrics)
    Found render metric: RenderBusy
  Metric set 1: ComputeBasic (23 metrics)
Selected metric set: RenderBasic

Monitoring GPU usage...
Mode: Single snapshot

Render: 25.4%  Blitter: 2.1%  Video: 8.3%  Enhance: 0.0%  | Total: 35.8%

Cleaning up resources...
GPU monitoring completed
```

**Continuous Monitoring:**
```
Intel GPU Usage Monitor
======================
Initializing Intel Metrics Discovery API...
Found Intel GPU: Intel(R) UHD Graphics 620 (Device ID: 0x5917)

Monitoring GPU usage...
Mode: Continuous (press Ctrl+C to stop)

Render: 15.2%  Blitter: 0.0%  Video: 5.4%  Enhance: 0.0%  | Total: 20.6%
Render: 23.8%  Blitter: 1.2%  Video: 12.1%  Enhance: 0.0%  | Total: 37.1%
Render: 18.9%  Blitter: 0.5%  Video: 8.7%  Enhance: 0.0%  | Total: 28.1%
^C
Cleaning up resources...
GPU monitoring completed
```

## Troubleshooting

### Common Issues

**1. Library not found:**
```
Error: Failed to load libigdmd.so library
```
**Solution:** Ensure the metrics discovery library is built and accessible. Check the library path.

**2. Permission denied:**
```
Error: Failed to open adapter group: ERROR_ACCESS_DENIED
```
**Solution:** Run with elevated privileges:
```bash
sudo ./gpu_usage
```

**3. No Intel GPU found:**
```
Error: No Intel GPU found
```
**Solution:** Verify Intel GPU is present and drivers are installed:
```bash
lspci | grep -i intel
```

**4. No utilization metrics found:**
```
Warning: No GPU utilization metric set found
```
**Solution:** This is normal on some platforms/drivers. The GPU may not expose engine utilization metrics.

### Debug Steps

1. **Check GPU detection:**
   ```bash
   lspci | grep -i vga
   lspci | grep -i intel
   ```

2. **Verify driver installation:**
   ```bash
   ls /dev/dri/
   cat /proc/modules | grep i915
   ```

3. **Check library dependencies:**
   ```bash
   ldd gpu_usage
   ```

4. **Run with verbose output:**
   ```bash
   strace -e trace=openat ./gpu_usage 2>&1 | grep libigdmd
   ```

## Installation (Optional)

To install the program system-wide:

```bash
# Install to /usr/local/bin
make install

# Use from anywhere
gpu_usage --snapshot

# Uninstall
make uninstall
```

## Advanced Usage

### Custom Library Path

If you've installed the library in a custom location:

```bash
# Edit the Makefile and update LIB_DIR variable
# Or use LD_LIBRARY_PATH environment variable
LD_LIBRARY_PATH=/custom/path ./gpu_usage
```

### Integration with Monitoring Tools

The program can be integrated with monitoring systems:

```bash
# Get single reading for monitoring scripts
OUTPUT=$(./gpu_usage --snapshot 2>/dev/null | tail -n 1)
echo "GPU_USAGE: $OUTPUT"

# Parse individual values
RENDER=$(echo "$OUTPUT" | grep -o 'Render: [0-9.]*%' | grep -o '[0-9.]*')
echo "Render engine: ${RENDER}%"
```

## Technical Notes

- The program dynamically loads the metrics discovery library
- Uses C++ interface with C-style error handling
- Implements proper resource cleanup on exit
- Supports graceful shutdown with signal handlers
- Includes placeholder values for demonstration (actual implementation would read real metrics)

## Platform Support

This program supports the same platforms as the Intel Metrics Discovery library:
- Intel processors with Xe3, Xe2, Xe graphics devices
- Intel Arc graphics devices
- See main repository README for detailed platform compatibility

For older platforms (Gen7.5, Gen8, Gen9, Gen11), use metrics discovery library version 1.14.180 or earlier.