# Nuke Installation Script Documentation

## Purpose
This script automates the installation of Foundry's Nuke software on Ubuntu, including setting up desktop entries, custom icons, and initialization files.

## Prerequisites

- A valid Nuke installer file (`.run` format) in your Downloads folder or a known location
- Custom icons in the script directory:
  - `nuke_icon.png` - Main Nuke application icon
  - `nukex_icon.png` - NukeX application icon
  - `nuke_folder_icon.png` - Folder icon for Nuke-related directories
- Sudo privileges
- GTK icon cache utilities installed

## Features

- Automatically detects the latest Nuke installer in the Downloads folder
- Allows manual path input if installer is not found
- Uses custom, branded icons for better visual integration
- Creates desktop entries for both Nuke and NukeX
- Sets up Nuke scripts directory with initialization file
- Creates command-line shortcuts
- Handles version extraction and management automatically

## Installation Process

1. Verifies presence of custom icons
2. Searches for Nuke installer in Downloads folder
3. If not found, prompts for manual path input
4. Extracts version information from the installer filename
5. Installs Nuke to `/usr/local`
6. Sets up application icons in the system
7. Creates desktop entries for Nuke and NukeX
8. Sets up Nuke scripts directory and initialization file
9. Creates command-line shortcuts
10. Updates the system icon cache

## Usage
```bash
./install_nuke.sh
```

If the installer is not found in Downloads, you will be prompted to enter the full path to the installer.

## Post-Installation
After installation, you can:

1. Launch Nuke from your applications menu
2. Pin the application to your dash
3. Run Nuke from terminal using `nukeX.YvZ` (e.g., `nuke15.1v5`)
4. Run NukeX from terminal using `nukexX.YvZ`
5. Find your Nuke scripts in `~/.nuke`

## Customization

The script sets up a basic `init.py` in your `~/.nuke` directory. You can modify this file to:
- Add custom plugins
- Set default preferences
- Add custom Python functions
- Configure default paths

Note: A system logout might be required for the application icons to appear correctly in the menu. 