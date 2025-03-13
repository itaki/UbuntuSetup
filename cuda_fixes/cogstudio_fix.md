# Fixing CogStudio CUDA Library Error

## Problem

When trying to generate a video with CogStudio in Pinokio, you encounter the following error:

```
Could not load library libcudnn_ops_infer.so.8. Error: libcudnn_ops_infer.so.8: cannot open shared object file: No such file or directory
Aborted (core dumped)
```

This error occurs because CogStudio cannot find the required CUDA libraries, specifically `libcudnn_ops_infer.so.8`.

## Solutions

We've created several solutions to address this issue, from least to most invasive:

### Solution 1: Use Environment Variables (Session-specific)

We've created two scripts to help with this:

1. `fix_cogstudio.sh` - Sets the correct environment variable
2. `launch_cogstudio.sh` - Sets the environment variable and launches CogStudio

#### Option 1A: Use the fix script before launching CogStudio

```bash
# First, source the fix script
source ~/UbuntuSetup/cuda_fixes/fix_cogstudio.sh

# Then navigate to the CogStudio directory and run it
cd ~/pinokio/api/cogstudio.git
python cogstudio.py
```

#### Option 1B: Use the launch script

```bash
# Simply run the launch script
~/UbuntuSetup/cuda_fixes/launch_cogstudio.sh
```

### Solution 2: Add Environment Variable to Pinokio (Pinokio-specific)

Add the `LD_LIBRARY_PATH` environment variable to Pinokio's configuration:

1. Open Pinokio
2. Click on the settings/gear icon
3. Add a new environment variable:
   - Variable name: `LD_LIBRARY_PATH`
   - Variable value: `/home/mm/pinokio/api/stable-diffusion-webui-forge.git/app/venv/lib/python3.10/site-packages/nvidia/cudnn/lib`
4. Save the configuration
5. Restart Pinokio
6. Try running CogStudio again

### Solution 3: System-wide Configuration (RECOMMENDED - CONFIRMED WORKING)

We've created two scripts for system-wide configuration:

1. `install_cudnn_config.sh` - Adds cuDNN library paths to the system's library search paths
2. `create_cudnn_symlinks.sh` - Creates symbolic links to the cuDNN libraries in standard system locations

#### Option 3A: Install system-wide configuration (CONFIRMED WORKING)

```bash
# Run the installation script with sudo
sudo ~/UbuntuSetup/cuda_fixes/install_cudnn_config.sh
```

This option has been tested and confirmed to fix the issue with CogStudio in Pinokio.

#### Option 3B: Create symbolic links in standard locations

```bash
# Run the symbolic link creation script with sudo
sudo ~/UbuntuSetup/cuda_fixes/create_cudnn_symlinks.sh
```

After running either of these scripts, restart Pinokio and try running CogStudio again.

### Solution 4: Enable Public Link for CogStudio

If you want to create a public link to share your CogStudio instance with others, you can use our script to modify the CogStudio code:

```bash
# Run the public link enablement script
~/UbuntuSetup/cuda_fixes/enable_public_link.sh
```

This script modifies the CogStudio code to add the `share=True` parameter to the `launch()` function, which enables the creation of a public link. After running this script, you can run CogStudio as usual, and it will display a public URL that you can share with others.

## Technical Details

The error occurs because the CUDA Deep Neural Network library (cuDNN) component `libcudnn_ops_infer.so.8` is not in the default library search path. This library is required for GPU-accelerated deep learning operations.

We found that the library exists on your system in several locations:

```
/usr/local/Nuke15.1v5/libcudnn_ops_infer.so.8
/home/mm/pinokio/api/stable-diffusion-webui-forge.git/app/venv/lib/python3.10/site-packages/nvidia/cudnn/lib/libcudnn_ops_infer.so.8
/home/mm/pinokio/api/svd.pinokio.git/generative-models/venv/lib/python3.10/site-packages/nvidia/cudnn/lib/libcudnn_ops_infer.so.8
/home/mm/pinokio/drive/drives/pip/nvidia-nvtx-cu12/12.1.105/lib/python3.10/site-packages/nvidia/cudnn/lib/libcudnn_ops_infer.so.8
```

Our solutions make these libraries available to CogStudio by:

1. Setting the `LD_LIBRARY_PATH` environment variable (Solutions 1 and 2)
2. Adding the library paths to the system's library search paths (Solution 3A) - **This method has been confirmed to work**
3. Creating symbolic links in standard system locations (Solution 3B)

## Troubleshooting

If you still encounter issues:

1. Make sure the library exists in the paths specified in the scripts
2. Try using a different library path from the list above
3. Check if there are any other CUDA-related errors in the logs
4. Verify that your GPU drivers are up to date
5. Check if there's a version mismatch between CUDA and cuDNN

Your system has CUDA 12.1 installed. Make sure the cuDNN version is compatible with this CUDA version. 