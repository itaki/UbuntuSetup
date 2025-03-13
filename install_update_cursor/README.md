# Cursor AI IDE Installation and Update Scripts

This directory contains scripts to install and automatically update the Cursor AI IDE on Ubuntu.

## Files

- `install_cursor.sh` - Installs or updates Cursor AI IDE
- `update_cursor.sh` - Script that checks for and installs Cursor updates
- `apply_pending_update.sh` - Script that applies pending updates when Cursor is not running
- `cursor-updater.desktop` - Desktop entry file for autostarting the updater
- `install_updater.sh` - Script to install the automatic updater

## Installation

### Installing Cursor

To install or update Cursor AI IDE:

```bash
chmod +x install_cursor.sh
./install_cursor.sh
```

This will:
- Install necessary dependencies
- Download the latest Cursor AppImage
- Create desktop entries and icons
- Add a shell alias for launching Cursor

### Installing the Automatic Updater

To install the automatic updater:

```bash
chmod +x install_updater.sh
./install_updater.sh
```

This will:
- Install the update scripts to `~/.local/bin/`
- Configure the updater to run on system startup
- Run the updater once to check for updates

## How the Updater Works

The update system consists of two parts:

1. **Update Checker** (`update_cursor.sh`):
   - Runs on system startup (after a 60-second delay)
   - Checks if a new version of Cursor is available
   - If Cursor is not running, it installs the update immediately
   - If Cursor is running, it downloads the update and saves it for later

2. **Update Applier** (`apply_pending_update.sh`):
   - Runs on system startup (after a 30-second delay)
   - Checks if there's a pending update to apply
   - Only applies updates when Cursor is not running
   - Creates a backup of the previous version before updating

Both scripts log all activities to `~/.local/share/cursor_update.log`.

## Important Notes

- The updater will never interrupt a running Cursor instance
- All your Cursor data (conversations, settings, extensions) are preserved during updates
- The data is stored in `~/.config/Cursor` and `~/.cursor` and is not affected by updates

## Manual Update

You can manually check for updates by running:

```bash
~/.local/bin/update_cursor.sh
```

To apply a pending update (when Cursor is not running):

```bash
~/.local/bin/apply_pending_update.sh
```

## Troubleshooting

If you encounter issues with the automatic updater, check the log file:

```bash
cat ~/.local/share/cursor_update.log
```

If Cursor fails to start after an update, the script will automatically restore the previous version. 