#!/bin/bash

# Main script to fix CUDA library issues
# This script will guide you through the different solutions

echo "=== CUDA Library Fix Tool ==="
echo ""
echo "This tool will help you fix issues with missing CUDA libraries."
echo "We've detected that you're having issues with the libcudnn_ops_infer.so.8 library."
echo ""
echo "Please choose one of the following solutions:"
echo ""
echo "1) Session-specific fix (sets environment variables for the current session)"
echo "2) Add environment variable to Pinokio configuration"
echo "3) System-wide configuration (RECOMMENDED - CONFIRMED WORKING, requires sudo)"
echo "4) Create symbolic links in standard locations (requires sudo)"
echo "5) Enable public link for CogStudio"
echo "6) View documentation"
echo "q) Quit"
echo ""

read -p "Enter your choice (1-6, q): " choice

case $choice in
  1)
    echo "Running session-specific fix..."
    source "$(dirname "$0")/fix_cogstudio.sh"
    echo ""
    echo "Now you can run CogStudio with:"
    echo "cd ~/pinokio/api/cogstudio.git"
    echo "python cogstudio.py"
    ;;
  2)
    echo "Showing instructions for adding environment variable to Pinokio..."
    "$(dirname "$0")/pinokio_env_fix.sh"
    ;;
  3)
    echo "Running system-wide configuration (RECOMMENDED - CONFIRMED WORKING, requires sudo)..."
    sudo "$(dirname "$0")/install_cudnn_config.sh"
    ;;
  4)
    echo "Creating symbolic links in standard locations (requires sudo)..."
    sudo "$(dirname "$0")/create_cudnn_symlinks.sh"
    ;;
  5)
    echo "Enabling public link for CogStudio..."
    "$(dirname "$0")/enable_public_link.sh"
    ;;
  6)
    echo "Viewing documentation..."
    if command -v less &> /dev/null; then
      less "$(dirname "$0")/cogstudio_fix.md"
    else
      cat "$(dirname "$0")/cogstudio_fix.md"
    fi
    ;;
  q|Q)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid choice. Please run the script again and select a valid option."
    exit 1
    ;;
esac

echo ""
echo "Done! If you still encounter issues, please try another solution or check the documentation." 