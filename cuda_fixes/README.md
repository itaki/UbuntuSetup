# CUDA Fixes

This directory contains scripts and documentation to fix common CUDA-related issues on Ubuntu.

## CogStudio Fix

The main issue addressed here is the missing `libcudnn_ops_infer.so.8` library when running CogStudio in Pinokio.

### Quick Start

Run the main fix script:

```bash
./fix_cuda_libraries.sh
```

This script will guide you through the different solutions available.

### Available Solutions

1. **Session-specific fix**: Sets environment variables for the current session
2. **Pinokio configuration**: Add environment variable to Pinokio's configuration
3. **System-wide configuration**: Adds cuDNN library paths to the system's library search paths (RECOMMENDED - CONFIRMED WORKING)
4. **Symbolic links**: Creates symbolic links to the cuDNN libraries in standard system locations

### Documentation

For detailed information about the issue and solutions, see [cogstudio_fix.md](cogstudio_fix.md).

## Files

- `fix_cuda_libraries.sh`: Main script to guide you through the different solutions
- `fix_cogstudio.sh`: Sets the correct environment variable for the current session
- `launch_cogstudio.sh`: Sets the environment variable and launches CogStudio
- `pinokio_env_fix.sh`: Instructions for adding environment variable to Pinokio
- `install_cudnn_config.sh`: Adds cuDNN library paths to the system's library search paths (CONFIRMED WORKING)
- `create_cudnn_symlinks.sh`: Creates symbolic links to the cuDNN libraries in standard system locations
- `cudnn-pinokio.conf`: Configuration file for the dynamic linker to find the cuDNN libraries
- `cogstudio_fix.md`: Detailed documentation about the issue and solutions 