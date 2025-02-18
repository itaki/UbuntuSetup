# Nuke Installation Script Documentation

## Purpose
This script automates the installation of Foundry's Nuke software on Ubuntu, including setting up desktop entries and icons.

## Prerequisites
- A valid Nuke installer file (`.run` format) in your Downloads folder or a known location
- Sudo privileges
- GTK icon cache utilities installed

## Features
- Automatically detects the latest Nuke installer in the Downloads folder
- Allows manual path input if installer is not found in Downloads
- Creates desktop entries for both Nuke and NukeX
- Sets up application icons
- Creates command-line shortcuts
- Handles version extraction and management automatically

## Installation Process
1. Searches for Nuke installer in Downloads folder
2. If not found, prompts for manual path input
3. Extracts version information from the installer filename
4. Installs Nuke to `/usr/local`
5. Sets up application icons in the system
6. Creates desktop entries for Nuke and NukeX
7. Creates command-line shortcuts
8. Updates the system icon cache

## Usage
```bash
./install_nuke.sh
```

If the installer is not found in Downloads, you will be prompted to enter the full path to the installer.

## Post-Installation
After installation, you can:
1. Launch Nuke from the applications menu
2. Pin the application to your dash
3. Run Nuke from terminal using `nukeX.YvZ` (e.g., `nuke15.1v5`)
4. Run NukeX from terminal using `nukexX.YvZ`

Note: A system logout might be required for the application icons to appear correctly in the menu. 