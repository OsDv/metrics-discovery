# Intel GPU Usage Monitor

A comprehensive C program that uses the Intel Metrics Discovery library to measure GPU usage on Intel UHD 620 integrated GPU and other supported Intel GPUs.

## Quick Start

### Automated Build (Recommended)

```bash
# Clone the repository
git clone https://github.com/intel/metrics-discovery.git
cd metrics-discovery

# Run the automated build script
./build_gpu_monitor.sh

# Run the GPU monitor
cd examples
./run_gpu_usage.sh --snapshot
```

### Manual Build

```bash
# 1. Install dependencies
sudo apt install build-essential cmake libdrm-dev  # Ubuntu/Debian
# OR
sudo dnf install gcc gcc-c++ cmake libdrm-devel   # Fedora/RHEL

# 2. Build Intel Metrics Discovery library
mkdir -p build && cd build
cmake ..
make -j$(nproc)

# 3. Build GPU Usage Monitor
cd ../examples
make

# 4. Run with library path
export LD_LIBRARY_PATH=../dump/linux64/release/metrics_discovery:$LD_LIBRARY_PATH
./gpu_usage --snapshot
```

## Program Features

### GPU Engine Monitoring
- **Render Engine**: 3D graphics rendering workload
- **Blitter Engine**: 2D graphics and memory operations
- **Video Engine**: Video encoding/decoding workload  
- **Enhance Engine**: Video enhancement operations (if available)

### Operating Modes
- **Snapshot Mode**: Single measurement with `--snapshot` or `-s`
- **Continuous Mode**: Real-time monitoring (updates every 1 second)

### Output Format
```
Render: 23.5%  Blitter: 0.0%  Video: 12.3%  Enhance: 0.0%  | Total: 35.8%
```

### Advanced Features
- Automatic Intel GPU detection
- Metric set enumeration and selection
- Usage normalization (total never exceeds 100%)
- Graceful shutdown with Ctrl+C
- Comprehensive error handling
- Dynamic library loading

## Usage Examples

### Basic Usage
```bash
# Help information
./run_gpu_usage.sh --help

# Single measurement
./run_gpu_usage.sh --snapshot

# Continuous monitoring (Ctrl+C to stop)
./run_gpu_usage.sh
```

### Integration with Scripts
```bash
# Capture single reading for scripting
OUTPUT=$(./run_gpu_usage.sh --snapshot 2>/dev/null | tail -n 1)
echo "Current GPU usage: $OUTPUT"

# Extract specific values
RENDER=$(echo "$OUTPUT" | grep -o 'Render: [0-9.]*%' | grep -o '[0-9.]*')
echo "Render engine usage: ${RENDER}%"
```

### System Monitoring Integration
```bash
# Add to crontab for periodic logging
# */5 * * * * /path/to/run_gpu_usage.sh --snapshot >> /var/log/gpu_usage.log

# Use with monitoring tools
watch -n 1 './run_gpu_usage.sh --snapshot'
```

## System Requirements

### Hardware Requirements
- **Intel GPU**: Any supported Intel integrated or discrete GPU
  - Intel UHD 620 (tested target)
  - Intel Xe, Xe2, Xe3 graphics
  - Intel Arc graphics devices
  - See compatibility table below

### Software Requirements
- **Linux Kernel**: 5.7 or later (varies by platform)
- **Mesa Driver**: 18.2 or later (varies by platform)
- **Build Tools**: GCC/G++ with C++11 support, CMake, Make
- **Libraries**: libdrm-dev/libdrm-devel

### Platform Compatibility

| Platform | Code Name | Min Kernel | Min Mesa | Status |
|----------|-----------|------------|----------|---------|
| Xe3-LPG | Panther Lake | 6.15 | 25.1 | ✅ Supported |
| Xe2-HPG | Battlemage | 6.11 | 24.2 | ✅ Supported |
| Xe2-LPG | Lunar Lake | 6.11 | 24.2 | ✅ Supported |
| Xe-LPG | Arrow Lake | 6.7+ | 24.1 | ✅ Supported |
| Xe-LPG | Meteor Lake | 6.7 | 23.1 | ✅ Supported |
| Xe-HPG | Alchemist | 6.2 | 22.2 | ✅ Supported |
| Xe-HPC | Ponte Vecchio | 5.20 | 18.2 | ✅ Supported |
| Xe-LP | Alder Lake | 5.16+ | 22.0+ | ✅ Supported |
| Xe-LP | Tiger Lake | 5.7 | 21.0 | ✅ Supported |
| Xe-LP | Rocket Lake | 5.13 | 20.2 | ✅ Supported |

## Installation Options

### Local Installation
```bash
# Install to /usr/local/bin (requires sudo)
cd examples
make install

# Use from anywhere
gpu_usage --snapshot

# Uninstall
make uninstall
```

### Custom Installation
```bash
# Install to custom directory
sudo cp examples/gpu_usage /opt/intel/bin/
sudo cp examples/run_gpu_usage.sh /opt/intel/bin/

# Create symlink in PATH
sudo ln -s /opt/intel/bin/run_gpu_usage.sh /usr/local/bin/gpu-monitor
```

## Troubleshooting

### Common Issues and Solutions

**1. Library not found**
```
Error: Failed to load libigdmd.so library
```
**Solution:**
```bash
# Check if library exists
ls dump/linux64/release/metrics_discovery/libigdmd.so

# Rebuild if missing
./build_gpu_monitor.sh
```

**2. Permission denied**
```
Error: Failed to open adapter group: ERROR_ACCESS_DENIED
```
**Solution:**
```bash
# Run with elevated privileges
sudo ./run_gpu_usage.sh --snapshot

# Or add user to video group (requires logout/login)
sudo usermod -a -G video $USER
```

**3. No Intel GPU found**
```
Error: No Intel GPU found
```
**Solution:**
```bash
# Check for Intel GPU
lspci | grep -i intel
lspci | grep -i vga

# Verify drivers are loaded
lsmod | grep i915
```

**4. No metrics available**
```
Warning: No GPU utilization metric set found
```
**Solution:** This is normal on some platforms. The GPU may not expose engine utilization metrics through this interface.

### Debug Commands

```bash
# Check GPU hardware
lspci | grep -E "(VGA|3D)"

# Check Intel graphics driver
dmesg | grep i915
cat /proc/modules | grep i915

# Check DRI devices
ls -la /dev/dri/

# Check library dependencies
ldd examples/gpu_usage

# Trace library loading
strace -e trace=openat ./gpu_usage 2>&1 | grep libigdmd
```

## Technical Implementation

### Architecture
```
Application (gpu_usage.c)
    ↓
Intel Metrics Discovery API (libigdmd.so)
    ↓
Linux DRM/Perf Subsystem
    ↓
Intel Graphics Driver (i915)
    ↓
Intel GPU Hardware
```

### API Usage Flow
1. **Library Loading**: Dynamically load `libigdmd.so`
2. **Adapter Discovery**: Enumerate and find Intel GPU adapters
3. **Metrics Device**: Open metrics device for selected adapter
4. **Metric Enumeration**: Find GPU engine utilization metric sets
5. **Measurement**: Activate metrics, collect data, deactivate
6. **Processing**: Calculate and normalize utilization percentages
7. **Cleanup**: Properly close all resources

### Key Components
- **Dynamic Loading**: No compile-time dependency on library location
- **Error Handling**: Comprehensive error checking at every API call
- **Resource Management**: Proper cleanup with signal handlers
- **Cross-Platform**: Works across different Intel GPU generations

## Development

### Building with Debug Info
```bash
# Debug build
cd examples
CXXFLAGS="-g -O0 -DDEBUG" make

# Run with debugger
gdb ./gpu_usage
```

### Custom Metrics
To add custom metrics, modify the `FindGpuUtilizationMetricSet()` function to search for additional metric names.

### Integration API
The program can be used as a library by extracting the core functions:
- `InitializeAPI()`
- `FindGpuUtilizationMetricSet()`
- `ReadGpuUtilization()`
- `Cleanup()`

## License

This program uses the Intel Metrics Discovery library, which is distributed under the MIT License. See the main repository LICENSE.md for details.

## Contributing

Contributions are welcome! Please see the main repository CONTRIBUTING.md for guidelines.

## Support

- **Issues**: Report bugs and feature requests on the GitHub repository
- **Documentation**: See the main metrics-discovery repository documentation
- **Community**: Intel Graphics community forums