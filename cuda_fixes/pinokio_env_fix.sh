#!/bin/bash

# Script to add LD_LIBRARY_PATH to Pinokio's environment
# This will create a new environment variable in Pinokio

echo "=== Adding LD_LIBRARY_PATH to Pinokio's environment ==="
echo ""
echo "In the Pinokio configuration screen, add a new environment variable:"
echo ""
echo "Variable name: LD_LIBRARY_PATH"
echo "Variable value: /home/mm/pinokio/api/stable-diffusion-webui-forge.git/app/venv/lib/python3.10/site-packages/nvidia/cudnn/lib"
echo ""
echo "Steps:"
echo "1. Open Pinokio"
echo "2. Click on the settings/gear icon"
echo "3. Add the new environment variable as shown above"
echo "4. Save the configuration"
echo "5. Restart Pinokio"
echo "6. Try running CogStudio again"
echo ""
echo "If that doesn't work, try these alternative paths for the LD_LIBRARY_PATH value:"
echo "/usr/local/Nuke15.1v5"
echo "/home/mm/pinokio/api/svd.pinokio.git/generative-models/venv/lib/python3.10/site-packages/nvidia/cudnn/lib"
echo "/home/mm/pinokio/drive/drives/pip/nvidia-nvtx-cu12/12.1.105/lib/python3.10/site-packages/nvidia/cudnn/lib" 