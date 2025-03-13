# Cursor Installation and Update Scripts

This directory contains scripts for installing and updating the Cursor AI IDE on Ubuntu.

## Scripts Overview

1. `install_cursor.sh` - Installs or updates Cursor AI IDE with user confirmation
2. `update_cursor.sh` - Checks for and downloads updates to Cursor (automated background updates)
3. `apply_pending_update.sh` - Applies pending updates when Cursor is not running (for automated updates)

## Implementation Details

### Interactive Installation/Update

The `install_cursor.sh` script now provides an interactive installation and update experience:

1. It checks if Cursor is already installed
2. It detects the current version and the latest available version
3. It prompts the user for confirmation before installing or updating
4. It creates a backup of the existing installation before updating
5. It restores the backup if the update fails

This approach ensures that:
- Users are aware of what version they're updating to
- No data is lost during the update process
- The update only proceeds with explicit user consent

### URL Selection

Initially, we used `https://downloader.cursor.sh/linux/appImage/x64` as the download URL, but we discovered this was causing issues with version control. Specifically, it was downloading an older version (45.14) instead of the latest version (46.11+).

We switched to using `https://cursor.so/resources/linux/cursor.appimage` which consistently provides the latest stable version.

### Version Checking

To prevent accidental downgrades, we implemented version checking in both the update and apply scripts:

1. We extract the version number from the AppImage using multiple methods:
   - Using the `--version` flag with specific pattern matching for Cursor versions (40-60 range)
   - Extracting from strings in the AppImage
   - Looking for version information in package.json
   - Validating that extracted versions match Cursor's version pattern (major version in 40s or 50s)
   - Fetching from the Cursor website as a fallback
   - Defaulting to the latest known version (46.11.0) if all else fails

2. We compare the major and minor version numbers to ensure we're only upgrading, not downgrading
3. We log the version information for debugging purposes

### Automated Update Process (Background Updates)

The automated update process works in two stages:

1. `update_cursor.sh` checks for updates and downloads them if available
   - If Cursor is running, it saves the update for later application
   - If Cursor is not running, it applies the update immediately

2. `apply_pending_update.sh` applies any pending updates when Cursor is not running
   - This is useful for applying updates that were downloaded while Cursor was running

### Dependencies

The scripts ensure that all necessary dependencies are installed:
- `curl` for downloading files
- `libfuse2` for running AppImages

### Shell Integration

The installation script adds a shell function to the user's shell configuration file (`.bashrc`, `.zshrc`, or `config.fish`) to make Cursor easily accessible from the command line.

## Usage

### Manual Installation/Update

To install or update Cursor manually:

```bash
./install_cursor.sh
```

This will:
1. Check if Cursor is already installed
2. Show the current and latest versions
3. Ask for confirmation before proceeding
4. Install or update Cursor while preserving user data

### Automated Updates

To set up automated updates, you can:

1. Run the update script periodically:
   ```bash
   ./update_cursor.sh
   ```

2. Apply pending updates when Cursor is not running:
   ```bash
   ./apply_pending_update.sh
   ```

## Troubleshooting

### Issue: Downgrading Instead of Upgrading

We encountered an issue where the update process was downgrading Cursor to version 45.14 instead of upgrading to 46.11+. This was caused by:

1. Using an outdated download URL that pointed to a specific version or channel
2. Lack of version checking in the update process
3. Difficulty in extracting version information from the AppImage

### Issue: Incorrect Version Detection

We also encountered an issue where the version detection was incorrectly identifying non-Cursor version numbers (like 8.35.0) from the AppImage. This was fixed by:

1. Adding specific pattern matching to look for Cursor's version format (major versions in the 40-60 range)
2. Validating extracted version numbers to ensure they match Cursor's versioning pattern
3. Providing clear fallback mechanisms when version detection fails

### Issue: Updates Not Applied After Restart

We found that the automated update process sometimes failed to apply updates after restarting Cursor. To address this, we:

1. Created a more reliable interactive update process via `install_cursor.sh`
2. Added better error handling and backup/restore functionality
3. Improved version detection and validation

### Solution:

1. Updated the download URL to `https://cursor.so/resources/linux/cursor.appimage`
2. Added robust version checking to prevent downgrades
3. Implemented multiple methods to extract version information
4. Added validation to ensure only legitimate Cursor versions are considered
5. Added fallback mechanisms to ensure version detection works reliably
6. Improved logging to show version information
7. Added interactive confirmation for updates
8. Implemented backup and restore functionality

### Other Potential Issues

- **FUSE Permissions**: If Cursor fails to run, check that FUSE is properly set up and the user has the necessary permissions
- **Shell Function**: If the `cursor` command doesn't work, try reloading your shell configuration with `source ~/.bashrc` (or equivalent)
- **Desktop Integration**: If Cursor doesn't appear in the application menu, try updating the desktop database with `update-desktop-database ~/.local/share/applications`

## Future Improvements

- Add support for beta/nightly channels
- Implement a more robust version comparison that handles patch versions
- Add a rollback feature to revert to a previous version if needed
- Create a systemd service to automatically check for updates on a schedule 