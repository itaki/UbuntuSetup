# Mac File Sharing Setup

This document explains how to set up file sharing between Ubuntu and macOS, allowing your Mac to see your Ubuntu machine in Finder.

## Overview

The `mac_file_sharing.sh` script sets up Samba file sharing with specific configurations to make it compatible with macOS. This allows your Ubuntu machine to appear in Finder's sidebar under "Locations" and enables easy file transfer between the two systems.

## What the Script Does

1. Installs Samba and related packages
2. Creates a backup of the original Samba configuration
3. Creates a new Samba configuration with Mac-specific settings
4. Creates a public shared directory
5. Adds the current user to Samba (requires setting a password)
6. Restarts Samba services
7. Configures the firewall to allow Samba traffic

## Shared Directories

The script sets up the following shared directories:

1. **Home** - Your home directory at `/home/mm`, accessible only to the authenticated user
2. **Public** - A public shared folder at `/home/shared` accessible to all users
3. **Sled** - The Sled drive mounted at `/media/mm/sled`, accessible only to the authenticated user

## Security and Performance Optimizations

The Samba configuration includes several optimizations:

1. **Security Settings**:
   - User-level security model
   - Password synchronization with system passwords
   - Restricted access to sensitive shares

2. **Performance Settings**:
   - Socket options for better network performance
   - Asynchronous I/O for improved file transfers
   - Sendfile optimization for better throughput

3. **Mac Compatibility**:
   - SMB2 protocol for modern macOS versions
   - Fruit VFS module for Apple-specific features
   - Metadata handling compatible with macOS

## Mac-Specific Samba Settings

The script configures several Mac-specific settings in Samba:

- `min protocol = SMB2` - Uses SMB2 protocol which is compatible with macOS
- `vfs objects = fruit streams_xattr` - Enables the "fruit" VFS module for Apple compatibility
- `fruit:metadata = stream` - Stores metadata in streams
- `fruit:model = MacSamba` - Identifies as a Mac-compatible Samba server
- Other fruit settings to handle Mac-specific file attributes and behaviors

## Troubleshooting

### If Your Ubuntu Machine Doesn't Appear in Finder

1. **Direct Connection**: In Finder, go to "Go" > "Connect to Server" and enter:
   ```
   smb://YOUR_UBUNTU_IP
   ```
   Replace YOUR_UBUNTU_IP with your Ubuntu machine's IP address.

2. **Check Firewall**: Ensure your firewall allows Samba traffic:
   ```
   sudo ufw status
   ```
   You should see rules allowing Samba.

3. **Check Samba Status**: Verify Samba is running:
   ```
   sudo systemctl status smbd
   ```

4. **Network Discovery**: Ensure both machines are on the same network and network discovery is enabled.

5. **Avahi/Bonjour**: For better discovery, you might need to install Avahi:
   ```
   sudo apt install avahi-daemon
   ```

### What Didn't Work

- **SMB1 Protocol**: Using the older SMB1 protocol is not recommended for security reasons and newer macOS versions don't support it well.
- **Default Samba Configuration**: The default configuration lacks the Apple-specific settings needed for proper integration.
- **Missing Fruit VFS Module**: Without the fruit VFS module, macOS has issues with file metadata and compatibility.

## Additional Notes

- The script creates a public shared folder at `/home/shared` accessible to all users.
- You'll need to set a Samba password for your user during the script execution.
- For security reasons, consider restricting access to specific users rather than allowing guest access in production environments. 