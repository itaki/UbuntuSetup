# Cursor Installation Script

This document explains the functionality and implementation details of the Cursor AI IDE installation script.

## Overview

The `install_cursor.sh` script provides a simple way to install or update the Cursor AI IDE on Ubuntu. It follows a straightforward workflow:

1. Check if Cursor is already installed
2. Determine the current version (if installed)
3. Check for the latest available version
4. Install or update Cursor based on user confirmation
5. Set up desktop integration and shell aliases

## Implementation Details

### Version Detection

The script uses multiple methods to detect the current and latest versions of Cursor:

1. For the installed version:
   - Runs the AppImage with `--version` flag
   - Extracts version information from the AppImage binary
   - Validates that the detected version matches Cursor's versioning pattern

2. For the latest version:
   - Checks the Cursor website for version information
   - Falls back to the downloads page if needed
   - If online version detection fails, offers to check both the repository and Downloads directory for Cursor AppImages
   - Scans for files matching the Cursor AppImage naming pattern (e.g., `Cursor-0.46.11-ae378be9dc2f5f1a6a1a220c6e25f9f03c8d4e19.deb.glibc2.25-x86_64.appimage`)
   - Extracts version information from filenames and selects the highest version available

### Version Comparison

The script compares versions using a three-part versioning scheme (major.minor.patch):
1. First compares major version numbers
2. If major versions are equal, compares minor version numbers
3. If both major and minor versions are equal, compares patch version numbers
4. Determines if an update is needed based on this comparison

### Process Management

Before updating, the script:
1. Checks if any Cursor processes are running
2. Offers to force-kill these processes if needed
3. Uses a multi-stage approach to ensure all processes are terminated

### Installation Process

The installation process:
1. Uses a downloaded AppImage from the repository or Downloads directory if available
2. Otherwise, downloads the latest Cursor AppImage from the official website
3. Creates a backup of the existing installation (if updating)
4. Installs the new version
5. Tests that the installation was successful
6. Restores from backup if the installation fails

### Desktop Integration

The script sets up proper desktop integration:
1. Creates a desktop entry file
2. Downloads and installs the Cursor icon
3. Updates the desktop database

### Shell Integration

For convenient command-line access, the script:
1. Detects the user's shell (bash, zsh, or fish)
2. Adds a shell function to the appropriate configuration file
3. Provides instructions for activating the new function

## Troubleshooting

Common issues and their solutions:

1. **FUSE Issues**: The script checks for and installs libfuse2, which is required for AppImages
2. **Permission Problems**: The script ensures proper permissions for FUSE devices
3. **Process Termination**: The script handles stubborn processes that resist termination

## Usage

To install or update Cursor:

```bash
./install_cursor.sh
```

The script will:
1. Check for dependencies and install them if needed
2. Show the current and latest versions
3. Ask for confirmation before proceeding
4. Install or update Cursor while preserving user data 