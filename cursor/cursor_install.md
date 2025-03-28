# Cursor Installation and Auto-Update

## Overview
This document describes the installation and auto-update setup for Cursor AI IDE. The setup includes automatic updates that run both daily and at system startup.

## Installation Script
The `install_cursor.sh` script handles the installation and updates for Cursor. It:
- Checks for the latest version from the official repository
- Downloads and installs the latest version if needed
- Preserves all user settings and preferences
- Runs completely automatically without user intervention
- Logs all activities for monitoring

## Automatic Updates
The system is configured to automatically check for and install updates in two ways:

### 1. Daily Updates
A cron job runs every day at 8 AM to check for and install updates. This ensures you always have the latest version even if your system stays on for extended periods.

### 2. Startup Updates
A systemd service runs at system startup to check for updates. This ensures you get any updates that may have been released while your system was off.

## Logging
All update activities are logged to:
```
/home/mm/UbuntuSetup/cursor/cursor_update.log
```

You can monitor this file to see what happened during updates.

## Managing Updates
The update service can be managed using systemd commands:
```bash
# Check service status
systemctl --user status cursor-update.service

# Stop the service
systemctl --user stop cursor-update.service

# Start the service
systemctl --user start cursor-update.service

# Disable automatic updates on startup
systemctl --user disable cursor-update.service

# Re-enable automatic updates on startup
systemctl --user enable cursor-update.service
```

## Troubleshooting
If updates aren't working as expected:
1. Check the log file for error messages
2. Ensure your system has internet connectivity
3. Verify that both the cron job and systemd service are enabled
4. Check system time is correct for the 8 AM updates 