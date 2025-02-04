#!/bin/bash

echo "Performing complete cleanup of NAS configurations..."

# Unmount any existing mounts
echo "Unmounting any existing mounts..."
sudo umount /mnt/tuxedomask* 2>/dev/null
sudo umount /mnt/TuxedoMask* 2>/dev/null

# Remove mount points
echo "Removing mount points..."
sudo rm -rf /mnt/tuxedomask* 2>/dev/null
sudo rm -rf /mnt/TuxedoMask* 2>/dev/null

# Remove credentials
echo "Removing credentials..."
rm -rf ~/.smbcredentials 2>/dev/null

# Clean up /etc/hosts entries
echo "Cleaning up hosts file..."
sudo sed -i '/tuxedomask/d' /etc/hosts
sudo sed -i '/TuxedoMask/d' /etc/hosts

# Clean up fstab entries
echo "Cleaning up fstab..."
sudo sed -i '/tuxedomask/d' /etc/fstab
sudo sed -i '/TuxedoMask/d' /etc/fstab

# Reset Samba configuration
echo "Resetting Samba configuration..."
if [ -f "/etc/samba/smb.conf.backup" ]; then
    sudo mv /etc/samba/smb.conf.backup /etc/samba/smb.conf
else
    sudo rm -f /etc/samba/smb.conf
    sudo touch /etc/samba/smb.conf
fi

# Clear gvfs cached credentials
echo "Clearing GVFS cached credentials..."
rm -rf ~/.local/share/gvfs-metadata/* 2>/dev/null

# Restart relevant services
echo "Restarting services..."
systemctl --user stop gvfs-daemon
systemctl --user stop gvfs-metadata
killall gvfsd-smb-browse 2>/dev/null
killall gvfsd-metadata 2>/dev/null
systemctl --user start gvfs-daemon

echo "Cleanup complete! Please log out and log back in to ensure all changes take effect." 