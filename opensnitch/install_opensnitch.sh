#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if curl and jq are installed
if ! command_exists curl; then
    echo "Installing curl..."
    sudo apt-get update
    sudo apt-get install -y curl
fi

if ! command_exists jq; then
    echo "Installing jq..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

# Current known versions
DAEMON_VERSION="1.6.6"
UI_VERSION="1.6.7"

echo "Installing OpenSnitch daemon version ${DAEMON_VERSION} and UI version ${UI_VERSION}"

# Download URLs
APP_DEB_URL="https://github.com/evilsocket/opensnitch/releases/download/v${DAEMON_VERSION}/opensnitch_${DAEMON_VERSION}-1_amd64.deb"
UI_DEB_URL="https://github.com/evilsocket/opensnitch/releases/download/v${UI_VERSION}/python3-opensnitch-ui_${UI_VERSION}-1_all.deb"

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download the packages
echo "Downloading OpenSnitch packages..."
curl -L -O "$APP_DEB_URL"
curl -L -O "$UI_DEB_URL"

# Install the packages
echo "Installing OpenSnitch..."
sudo dpkg -i opensnitch_${DAEMON_VERSION}-1_amd64.deb
sudo dpkg -i python3-opensnitch-ui_${UI_VERSION}-1_all.deb

# Fix any dependency issues
sudo apt-get install -f -y

# Clean up
cd - >/dev/null
rm -rf "$TEMP_DIR"

echo "OpenSnitch installation completed!" 