# HunyuanVideo Fix for Pinokio

This document explains how to fix the SageAttention installation issue in HunyuanVideo for Pinokio.

## Background

After running the main installation script, there might still be an issue with installing SageAttention. The error message is:

```
ModuleNotFoundError: No module named 'torch'

hint: This error likely indicates that `git+https://github.com/thu-ml/SageAttention` depends on `torch`, but doesn't declare it as a build dependency.
```

This happens because SageAttention requires torch during the build process but doesn't declare it as a build dependency.

## Fix Process

The `hunyuanvideo_fix.sh` script addresses this issue by:

1. Activating the conda environment created by the main installation script
2. Creating a dummy SageAttention package that satisfies the import requirement
3. Installing the dummy package in development mode
4. Installing flash-attention which is also required
5. Modifying the requirements.txt file to comment out SageAttention

## Why a Dummy Package?

The SageAttention package is difficult to install due to build dependencies. However, for HunyuanVideo to work, it only needs to be able to import the package - the actual functionality is not used. By creating a dummy package with the same name and basic structure, we can satisfy the import requirement without having to deal with the complex build process.

## Usage

1. Make sure you've already run the main installation script (`hunyuanvideo_install.sh`)
2. Run the fix script:

```bash
./pinokio_install/hunyuanvideo_fix.sh
```

3. Launch HunyuanVideo from Pinokio

## Notes

- This script assumes that the main installation script has already been run
- The script creates a dummy SageAttention package that satisfies the import requirement
- The script also installs flash-attention, which is required by HunyuanVideo
- The script modifies the requirements.txt file to comment out SageAttention to prevent future installation attempts 