#!/bin/bash

# Install required packages
echo "Installing required packages..."
sudo apt update
sudo apt install -y samba samba-common gvfs-backends gvfs-fuse

# Configure Samba
echo "Configuring Samba settings..."
SMB_CONF="/etc/samba/smb.conf"

# Backup existing config if it exists
if [ -f "$SMB_CONF" ]; then
    sudo cp "$SMB_CONF" "${SMB_CONF}.backup"
fi

# Add our configuration
sudo tee -a "$SMB_CONF" > /dev/null <<EOL
[global]
client min protocol = SMB2
client max protocol = SMB3
security = user
name resolve order = bcast host
ntlm auth = yes
client use spnego = yes
disable netbios = yes
EOL

# Restart GVFS daemon
echo "Restarting GVFS daemon..."
systemctl --user restart gvfs-daemon

echo "Setup complete! You can now connect to TuxedoMask through the file browser:"
echo "1. Open the file browser"
echo "2. Click 'Other Locations' at the bottom of the sidebar"
echo "3. Click on 'TuxedoMask' or enter 'smb://TuxedoMask' in the address bar"
echo "4. Enter your QNAP username and password when prompted"
echo "5. Check 'Remember forever' to save your credentials"