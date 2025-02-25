#!/bin/bash
#########################################################
# TCMalloc Installation Script for Pinokio Forge Docker
# This script installs and configures TCMalloc inside the
# Pinokio Forge Docker container for improved memory management
#########################################################

# Set variables
CONTAINER_NAME="pinokio_forge"
TCMALLOC_PATH="/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4"
WEBUI_USER_PATH="/app/webui-user.sh"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running or not accessible"
    exit 1
fi

# Check if the container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container '${CONTAINER_NAME}' not found"
    echo "Please specify the correct container name by editing this script"
    exit 1
fi

# Check if the container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container '${CONTAINER_NAME}' is not running. Starting it now..."
    docker start "${CONTAINER_NAME}"
    sleep 5
fi

echo "Installing TCMalloc in the ${CONTAINER_NAME} container..."

# Install TCMalloc inside the container
docker exec "${CONTAINER_NAME}" bash -c "
    # Update package lists
    apt-get update

    # Install TCMalloc (Google Perftools)
    apt-get install -y google-perftools libgoogle-perftools-dev

    # Verify installation
    if [ ! -f '${TCMALLOC_PATH}' ]; then
        echo 'Error: TCMalloc library not found after installation'
        exit 1
    fi

    echo 'TCMalloc successfully installed'
"

# Check if installation was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to install TCMalloc in the container"
    exit 1
fi

echo "Configuring webui-user.sh to use TCMalloc..."

# Update webui-user.sh to use TCMalloc
docker exec "${CONTAINER_NAME}" bash -c "
    # Backup the original file
    cp '${WEBUI_USER_PATH}' '${WEBUI_USER_PATH}.backup'

    # Check if LD_PRELOAD is already set
    if grep -q 'export LD_PRELOAD=' '${WEBUI_USER_PATH}'; then
        # Update existing LD_PRELOAD
        sed -i 's|export LD_PRELOAD=.*|export LD_PRELOAD=${TCMALLOC_PATH}:\$LD_PRELOAD|' '${WEBUI_USER_PATH}'
    else
        # Add LD_PRELOAD before the last line
        sed -i '\$i export LD_PRELOAD=${TCMALLOC_PATH}' '${WEBUI_USER_PATH}'
    fi

    # Add TCMalloc configuration
    if ! grep -q 'TCMALLOC_LARGE_ALLOC_REPORT_THRESHOLD' '${WEBUI_USER_PATH}'; then
        sed -i '\$i export TCMALLOC_LARGE_ALLOC_REPORT_THRESHOLD=1073741824' '${WEBUI_USER_PATH}'
    fi
    
    if ! grep -q 'TCMALLOC_RELEASE_RATE' '${WEBUI_USER_PATH}'; then
        sed -i '\$i export TCMALLOC_RELEASE_RATE=10.0' '${WEBUI_USER_PATH}'
    fi

    echo 'webui-user.sh updated to use TCMalloc'
"

# Check if configuration was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to configure webui-user.sh"
    exit 1
fi

echo "TCMalloc installation and configuration completed successfully"
echo "Restart the Pinokio Forge container to apply changes"
echo "You can restart with: docker restart ${CONTAINER_NAME}" 