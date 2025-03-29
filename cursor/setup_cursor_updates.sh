#!/bin/bash

# Script to set up Cursor auto-updates
# This script installs the update script and sets up cron job for nightly updates

# Define paths
LOCAL_BIN="$HOME/.local/bin"
UPDATE_SCRIPT="$LOCAL_BIN/update_cursor.sh"
CRON_JOB="0 0 * * * $UPDATE_SCRIPT"
DESKTOP_ENTRY="$HOME/.config/autostart/cursor-updater.desktop"

# Create local bin directory if it doesn't exist
mkdir -p "$LOCAL_BIN"

# Copy the update script to local bin
echo "Installing update script..."
cp "$(dirname "$0")/update_cursor.sh" "$UPDATE_SCRIPT"
chmod +x "$UPDATE_SCRIPT"

# Set up cron job
echo "Setting up cron job for nightly updates..."
(crontab -l 2>/dev/null | grep -v "$UPDATE_SCRIPT"; echo "$CRON_JOB") | crontab -

# Verify cron job was added
if crontab -l 2>/dev/null | grep -q "$UPDATE_SCRIPT"; then
    echo "Cron job successfully added for nightly updates at midnight."
else
    echo "Failed to add cron job. Please check your crontab manually."
    exit 1
fi

# Set up startup entry
echo "Setting up startup entry..."
mkdir -p "$HOME/.config/autostart"
cat > "$DESKTOP_ENTRY" <<EOL
[Desktop Entry]
Type=Application
Name=Cursor Updater
Comment=Checks for and installs Cursor AI IDE updates
Exec=/bin/bash -c "sleep 60 && $UPDATE_SCRIPT"
Terminal=false
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOL

# Make desktop entry executable
chmod +x "$DESKTOP_ENTRY"

echo "Setup complete! Cursor will now check for updates:"
echo "- On system startup (after 60 seconds)"
echo "- Nightly at midnight"
echo "To test the update script, please open a new terminal and run:"
echo "$UPDATE_SCRIPT" 