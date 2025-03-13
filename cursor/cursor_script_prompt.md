# Cursor Installation Script Documentation

## Overview
This script installs or updates the Cursor AI IDE on Ubuntu systems. It handles both new installations and updates, with special handling for new installations to set up dependencies and desktop integration.

## Implementation Details

### Information Section
- Checks if Cursor is already installed by looking for the AppImage in `~/.local/bin`
- Fetches the latest version information from the official GitHub repository
- Falls back to checking for recent AppImages in Downloads directory if online check fails
- Extracts version and download URL from the repository data

### Install Section
- Always prompts user for permission to install/update
- Kills any running Cursor processes to prevent conflicts
- Downloads the latest AppImage from the official source
- Makes the AppImage executable
- Preserves user preferences and settings during updates

### New Install Section
- Only runs for new installations
- Checks for required dependencies (curl, libfuse2)
- Offers to install missing dependencies
- Sets up FUSE permissions and group membership
- Creates desktop entry and icon if requested
- Updates desktop database

### Exit Section
- Provides installation summary
- Offers to launch Cursor with `--no-sandbox` flag
- Reports success or failure of installation

## Technical Notes

### Dependencies
- curl: For downloading files
- libfuse2: Required for AppImage execution
- FUSE group membership: For proper AppImage functionality

### File Locations
- AppImage: `~/.local/bin/cursor.appimage`
- Desktop Entry: `~/.local/share/applications/cursor.desktop`
- Icon: `~/.local/share/icons/cursor.png`

### Important Flags
- `--no-sandbox`: Required for running Cursor on some Linux systems
- `%F`: Used in desktop entry to handle file opening

## Implementation Challenges and Solutions

1. **Version Extraction**
   - Challenge: GitHub repository structure changed
   - Solution: Implemented robust JSON parsing with fallback to local files

2. **Process Management**
   - Challenge: Need to safely kill running instances
   - Solution: Added careful process detection and termination

3. **Sandbox Issues**
   - Challenge: AppImage sandbox errors on some systems
   - Solution: Added `--no-sandbox` flag to launch command

4. **Desktop Integration**
   - Challenge: Desktop entry permissions and database updates
   - Solution: Added proper permissions and error handling

## Usage
```bash
./install_cursor.sh
```

The script will:
1. Check current installation status
2. Get latest version information
3. Ask for permission to install/update
4. Handle the installation process
5. Set up desktop integration for new installs
6. Offer to launch Cursor

## Future Improvements
1. Add version comparison to prevent unnecessary updates
2. Implement backup/restore functionality
3. Add support for different installation locations
4. Improve error handling for network issues
5. Add support for different desktop environments





