#!/bin/bash

echo "Cleaning up old NAS mount entries..."

# Unmount any existing mounts
echo "Unmounting any existing mounts..."
sudo umount /mnt/tuxedomask 2>/dev/null
sudo umount /mnt/TuxedoMask 2>/dev/null

# Remove old mount points
echo "Removing old mount points..."
sudo rm -rf /mnt/tuxedomask 2>/dev/null
sudo rm -rf /mnt/TuxedoMask 2>/dev/null

# Remove old credentials
echo "Removing old credentials..."
rm -f ~/.smbcredentials/tuxedomask 2>/dev/null
rm -f ~/.smbcredentials/TuxedoMask 2>/dev/null

# Remove entries from /etc/hosts
echo "Cleaning up /etc/hosts..."
sudo sed -i '/tuxedomask/d' /etc/hosts
sudo sed -i '/TuxedoMask/d' /etc/hosts

# Remove entries from /etc/fstab
echo "Cleaning up /etc/fstab..."
sudo sed -i '/tuxedomask/d' /etc/fstab
sudo sed -i '/TuxedoMask/d' /etc/fstab

# Reload systemd
echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Cleanup complete! You can now run the new setup script." 