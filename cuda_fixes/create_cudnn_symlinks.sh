#!/bin/bash

# Script to create symbolic links for cuDNN libraries in standard locations
# This will make the cuDNN libraries available to applications that look in standard locations

echo "=== Creating symbolic links for cuDNN libraries ==="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root (with sudo)"
  exit 1
fi

# Source library path
SRC_LIB="/home/mm/pinokio/api/stable-diffusion-webui-forge.git/app/venv/lib/python3.10/site-packages/nvidia/cudnn/lib/libcudnn_ops_infer.so.8"

# Check if the source library exists
if [ ! -f "$SRC_LIB" ]; then
  echo "Error: Source library not found at $SRC_LIB"
  echo "Please check the path and try again."
  exit 1
fi

# Target directories
TARGET_DIRS=(
  "/usr/lib"
  "/usr/lib/x86_64-linux-gnu"
  "/usr/local/cuda/lib64"
)

# Create symbolic links
for dir in "${TARGET_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "Creating symbolic link in $dir"
    ln -sf "$SRC_LIB" "$dir/libcudnn_ops_infer.so.8"
    echo "Created: $dir/libcudnn_ops_infer.so.8 -> $SRC_LIB"
  else
    echo "Directory $dir does not exist, skipping"
  fi
done

# Update the dynamic linker run-time bindings
echo "Updating dynamic linker cache with ldconfig"
ldconfig

echo "Done! The cuDNN libraries should now be available in standard locations."
echo "Please restart Pinokio and try running CogStudio again." 