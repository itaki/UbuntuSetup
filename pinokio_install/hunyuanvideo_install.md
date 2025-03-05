# HunyuanVideo Installation for Pinokio

This document explains the process of installing HunyuanVideo correctly in Pinokio.

## Background

HunyuanVideo is an AI video generation model developed by Tencent. When installing it through Pinokio, several issues can occur:

1. The git clone fails because the destination directory 'app' already exists
2. There are dependency issues with PyTorch and SageAttention
3. There are version compatibility issues with numpy
4. The Python environment setup needs to use Pinokio's specific conda installation

## Installation Process

The `hunyuanvideo_install.sh` script addresses these issues by:

1. Backing up the existing app directory
2. Cloning the repository fresh
3. Setting up a conda environment with Python 3.10 using Pinokio's conda installation
4. Installing dependencies in the correct order:
   - PyTorch with CUDA support first
   - Specific numpy version (1.24.4)
   - Other requirements
   - SageAttention with build isolation disabled
   - Flash-attention
5. Creating the necessary symbolic links and activation script for Pinokio to use

## Issues Encountered and Solutions

### Issue 1: Git Clone Failure

When trying to install HunyuanVideo through Pinokio, the git clone command fails with:

```
fatal: destination path 'app' already exists and is not an empty directory.
```

**Solution**: The script backs up the existing app directory before cloning the repository.

### Issue 2: Python Environment Setup

The initial script used a standard Python virtual environment, but Pinokio uses a specific conda installation:

```
./pinokio_install/hunyuanvideo_install.sh: line 42: conda: command not found
```

**Solution**: The script now uses Pinokio's specific conda installation located at `~/pinokio/bin/miniconda/bin/conda` to create and manage the Python environment.

### Issue 3: SageAttention Installation Failure

The installation of SageAttention fails with:

```
ModuleNotFoundError: No module named 'torch'
```

This happens because SageAttention requires torch during the build process but doesn't declare it as a build dependency.

**Solution**: The script installs PyTorch first and then installs SageAttention with the `--no-build-isolation` flag.

### Issue 4: Numpy Version Compatibility

There are compatibility issues with numpy versions:

```
- numpy==2.1.2
+ numpy==1.24.4
```

**Solution**: The script explicitly installs numpy version 1.24.4 which is compatible with the other dependencies.

### Issue 5: Environment Activation for Pinokio

Pinokio expects a specific directory structure for the Python environment:

```
source /home/mm/pinokio/api/hunyuanvideo.git/app/env/bin/activate
```

**Solution**: The script creates symbolic links and an activation script that Pinokio can use to activate the conda environment.

## Usage

1. Make sure Pinokio is installed
2. Install HunyuanVideo from Pinokio (it will fail, but that's expected)
3. Run the `hunyuanvideo_install.sh` script to fix the installation
4. Launch HunyuanVideo from Pinokio

## Notes

- The script creates a backup of the existing app directory, so you can restore it if needed
- The script uses Pinokio's specific conda installation to create and manage the Python environment
- The script creates symbolic links and an activation script that Pinokio can use to activate the conda environment 