# Fixing CogStudio CUDA Library Error

## Problem

When trying to generate a video with CogStudio in Pinokio, you encounter the following error:

```
Could not load library libcudnn_ops_infer.so.8. Error: libcudnn_ops_infer.so.8: cannot open shared object file: No such file or directory
Aborted (core dumped)
```

This error occurs because CogStudio cannot find the required CUDA libraries, specifically `libcudnn_ops_infer.so.8`.

## Solution

The solution is to set the `LD_LIBRARY_PATH` environment variable to include the directory containing the required library. We've created two scripts to help with this:

1. `fix_cogstudio.sh` - Sets the correct environment variable
2. `launch_cogstudio.sh` - Sets the environment variable and launches CogStudio

### Option 1: Use the fix script before launching CogStudio

```bash
# First, source the fix script
source ~/UbuntuSetup/fix_cogstudio.sh

# Then navigate to the CogStudio directory and run it
cd ~/pinokio/api/cogstudio.git
python cogstudio.py
```

### Option 2: Use the launch script (recommended)

```bash
# Simply run the launch script
~/UbuntuSetup/launch_cogstudio.sh
```

### Option 3: Modify Pinokio's environment

If you want a more permanent solution, you can modify Pinokio's environment configuration to include the required library path. This would depend on how Pinokio manages environment variables for its applications.

## Technical Details

The error occurs because the CUDA Deep Neural Network library (cuDNN) component `libcudnn_ops_infer.so.8` is not in the default library search path. This library is required for GPU-accelerated deep learning operations.

We found that the library exists on your system in several locations:

```
/usr/local/Nuke15.1v5/libcudnn_ops_infer.so.8
/home/mm/pinokio/api/stable-diffusion-webui-forge.git/app/venv/lib/python3.10/site-packages/nvidia/cudnn/lib/libcudnn_ops_infer.so.8
/home/mm/pinokio/api/svd.pinokio.git/generative-models/venv/lib/python3.10/site-packages/nvidia/cudnn/lib/libcudnn_ops_infer.so.8
/home/mm/pinokio/drive/drives/pip/nvidia-nvtx-cu12/12.1.105/lib/python3.10/site-packages/nvidia/cudnn/lib/libcudnn_ops_infer.so.8
```

Our solution adds one of these paths to the `LD_LIBRARY_PATH` environment variable, which tells the system where to look for shared libraries.

## Troubleshooting

If you still encounter issues:

1. Make sure the library exists in the path specified in the scripts
2. Try using a different library path from the list above
3. Check if there are any other CUDA-related errors in the logs
4. Verify that your GPU drivers are up to date 