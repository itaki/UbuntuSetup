# WebUI User Configuration Notes

## Recent Changes
- Added TCMalloc integration:
  - Installed Google Performance Tools inside Docker container
  - Configured LD_PRELOAD to use TCMalloc
  - Optimized TCMalloc parameters for AI workloads
  - Added memory allocation monitoring
- Added performance optimization packages:
  - Flash Attention 2: Optimized attention mechanism
  - Better Transformer: Enhanced transformer operations
  - NVIDIA DALI: Accelerated data loading
  - NVIDIA Apex: Optimized CUDA operations
  - CuPy: Fast CUDA operations
  - Numba: JIT compilation support
  - PyTorch TensorRT: TensorRT integration
- Enhanced CUDA configuration:
  - Enabled virtual memory compression
  - Configured JIT fast math
  - Enabled L2 cache persistence
  - Optimized memory pool initialization
- Enhanced memory management:
  - Increased memory block size to 4096MB for RTX 3090
  - Added power-of-2 memory alignment
  - Enabled cuDNN v8 API
  - Optimized system memory allocation
- Improved CUDA performance:
  - Added GPU auto-boost
  - Optimized JIT compilation
  - Enhanced attention mechanisms
  - Disabled unnecessary checks

## Accelerate Configuration

### Important Changes
- Modified `webui.sh` to properly handle accelerate configuration file
- Added support for both config file and default parameters
- Fixed warnings about unspecified accelerate parameters
- Simplified accelerate config to use only essential parameters

### How it Works
The launch script now checks for configuration in this order:
1. Checks if accelerate is enabled (`ACCELERATE="True"`)
2. Checks if accelerate config file is specified (`ACCELERATE_CONFIG_FILE`)
3. If config file exists, uses `--config_file` parameter
4. If no config file, falls back to default `--num_cpu_threads_per_process=6`

### Configuration Files
Two main configuration files are used:
1. `webui-user.sh`: Environment variables and command line arguments
2. `accelerate_config.yaml`: Accelerate-specific configuration

## Current Performance Metrics
Based on latest startup:
- Total startup time: 11.0s
  - Environment preparation: 0.4s
  - Launcher: 0.4s
  - Torch import: 4.5s
  - Other imports: 0.3s
  - Script loading: 1.3s
  - UI creation: 1.7s
  - Gradio launch: 1.4s
  - API addition: 0.9s

- Memory Usage:
  - Total VRAM: 24250 MB
  - Total RAM: 128730 MB
  - Model loading time: 2.2s
    - Unload existing: 0.3s
    - Forge model load: 2.0s

## Optimization Components

### 1. Memory Management
- TCMalloc Integration:
  - Using libtcmalloc_minimal.so.4 from Google Performance Tools
  - Configured with LD_PRELOAD in Docker container
  - Optimized parameters:
    - TCMALLOC_LARGE_ALLOC_REPORT_THRESHOLD=1073741824 (1GB)
    - TCMALLOC_RELEASE_RATE=10.0
  - Benefits:
    - Reduced memory fragmentation
    - Faster allocation/deallocation
    - Thread-local caching for improved concurrency
    - Better handling of large memory blocks
  - Installation:
    - Automated via install-tcmalloc.sh script
    - Installs directly inside Docker container
    - Modifies webui-user.sh automatically

### 2. CUDA Optimization
- Core Settings:
  - cudaMallocAsync backend
  - Virtual memory compression
  - L2 cache persistence
  - JIT fast math enabled
  - Wave64 execution

### 3. PyTorch Configuration
- Memory Settings:
  - 4096MB split size
  - 0.9 GC threshold
  - Power-of-2 alignment
  - Expandable segments
  - cudaMallocAsync backend

### 4. Acceleration Packages
- Flash Attention 2:
  - Optimized attention computation
  - Reduced memory usage
  - Improved speed for transformer operations

- NVIDIA DALI:
  - Accelerated data loading
  - GPU-accelerated preprocessing
  - Optimized memory transfers

- NVIDIA Apex:
  - Mixed precision training
  - Optimized CUDA kernels
  - Fused optimizers

- Additional Tools:
  - CuPy: GPU-accelerated array operations
  - Numba: JIT compilation for Python code
  - TensorRT: Optimized inference

## Current Optimizations
- CUDA optimizations:
  - `

## Troubleshooting
[Previous troubleshooting section remains unchanged...]