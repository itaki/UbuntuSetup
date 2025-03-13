#!/bin/bash

# Script to modify CogStudio to enable public sharing
# This will add the share=True parameter to the launch() function

echo "=== Enabling public link for CogStudio ==="

# Path to the CogStudio main file
COGSTUDIO_PATH=~/pinokio/api/cogstudio.git/cogstudio.py

# Check if the file exists
if [ ! -f "$COGSTUDIO_PATH" ]; then
  echo "Error: CogStudio file not found at $COGSTUDIO_PATH"
  echo "Please check the path and try again."
  exit 1
fi

# Create a backup of the original file
cp "$COGSTUDIO_PATH" "${COGSTUDIO_PATH}.bak"
echo "Created backup at ${COGSTUDIO_PATH}.bak"

# Replace the launch() function call
sed -i 's/demo.launch()/demo.launch(share=True)/' "$COGSTUDIO_PATH"

# Check if the modification was successful
if grep -q "demo.launch(share=True)" "$COGSTUDIO_PATH"; then
  echo "Successfully modified CogStudio to enable public link."
  echo "Now when you run CogStudio, it will create a public link that you can share."
  echo ""
  echo "To run CogStudio with the fix and public link:"
  echo "1. First apply the CUDA library fix if you haven't already:"
  echo "   sudo ~/UbuntuSetup/cuda_fixes/install_cudnn_config.sh"
  echo ""
  echo "2. Then run CogStudio:"
  echo "   cd ~/pinokio/api/cogstudio.git"
  echo "   python cogstudio.py"
  echo ""
  echo "3. Look for a message like this in the output:"
  echo "   'Running on public URL: https://xxx-xxx-xxx.gradio.live'"
else
  echo "Error: Failed to modify CogStudio."
  echo "Please check the file manually and make the change:"
  echo "Change 'demo.launch()' to 'demo.launch(share=True)' in $COGSTUDIO_PATH"
  # Restore the backup
  cp "${COGSTUDIO_PATH}.bak" "$COGSTUDIO_PATH"
  echo "Restored the original file from backup."
fi 