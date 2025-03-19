# Pinokio Installation

## Overview
This script installs Pinokio, a platform for running AI applications locally on your computer. Pinokio allows you to run various AI models and tools with a simple interface.

## Links
- Main website: https://pinokio.computer/
- GitHub repository: https://github.com/pinokiocomputer/pinokio/releases/tag/3.6.23

## Installation Methods

### Method 1: Using Ubuntu App Center (Recommended)
1. Download the Pinokio .deb package from the GitHub releases page:
   - Go to https://github.com/pinokiocomputer/pinokio/releases/tag/3.6.23
   - Download the `Pinokio_3.6.23_amd64.deb` file
2. Open the downloaded .deb file with the Ubuntu App Center
3. Click "Install" and enter your password when prompted
4. Wait for the installation to complete

### Method 2: Using the Installation Script
The installation script (`pinokio_install.sh`) performs the following actions:

1. Checks for the downloaded .deb package in the Downloads directory
2. Installs the package using dpkg
3. Automatically installs any missing dependencies using apt-get
4. Creates desktop shortcuts for easy access

To use the script:
```bash
chmod +x pinokio_install.sh
./pinokio_install.sh
```

## After Installation
You can start Pinokio by:
- Running `pinokio` from the terminal
- Clicking on the Pinokio icon in your applications menu

### Fixing Desktop Shortcut Issues
If Pinokio doesn't appear in your applications menu or desktop after installation, run the fix script:
```bash
chmod +x fix_desktop_shortcut.sh
./fix_desktop_shortcut.sh
```

This script creates desktop shortcuts in both your Desktop folder and local applications directory. If you still don't see Pinokio in your applications menu after running the fix script, try logging out and back in to refresh the desktop environment.

### Setting Up Protocol Handler
Pinokio uses a custom protocol (`pinokio://`) to handle installation of applications from websites. If clicking on Pinokio links opens the App Center instead of Pinokio, run the protocol handler fix script:
```bash
chmod +x fix_protocol_handler.sh
./fix_protocol_handler.sh
```

This script registers Pinokio as the default handler for the `pinokio://` protocol and creates a test link on your desktop to verify it works. After running the script, you should be able to click on links like:
```
pinokio://download?uri=https://github.com/facefusion/facefusion-pinokio
```
And they will open directly in Pinokio instead of the App Center.

## System Requirements
- Ubuntu Linux (or other Debian-based distributions)
- x86_64 architecture
- Internet connection for downloading the package

## Notes
- The installation requires administrative privileges
- The download size is approximately 100MB
- The application is installed in `/opt/Pinokio/`

## Troubleshooting
If you encounter any issues during installation:
- Make sure the .deb file has been downloaded correctly
- Ensure you have administrative privileges
- Check your internet connection if dependency installation fails
- If the application doesn't appear in the menu, run the `fix_desktop_shortcut.sh` script
- If Pinokio links open in the wrong application, run the `fix_protocol_handler.sh` script
- If protocol handling still doesn't work after running the fix script, try logging out and back in