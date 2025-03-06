#!/bin/bash

# Script to install cuDNN configuration for system-wide access
# This will make the cuDNN libraries available to all applications

echo "=== Installing cuDNN configuration for system-wide access ==="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root (with sudo)"
  exit 1
fi

# Copy the configuration file to /etc/ld.so.conf.d/
echo "Copying configuration file to /etc/ld.so.conf.d/"
cp "$(dirname "$0")/cudnn-pinokio.conf" /etc/ld.so.conf.d/

# Update the dynamic linker run-time bindings
echo "Updating dynamic linker cache with ldconfig"
ldconfig

echo "Done! The cuDNN libraries should now be available system-wide."
echo "Please restart Pinokio and try running CogStudio again." 