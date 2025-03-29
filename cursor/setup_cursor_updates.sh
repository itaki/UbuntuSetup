#!/bin/bash

# Script to set up Cursor auto-updates
# This script installs the update script and sets up cron job for nightly updates

# Define paths
LOCAL_BIN="$HOME/.local/bin"
UPDATE_SCRIPT="$LOCAL_BIN/update_cursor.sh"
CRON_JOB="0 0 * * * $UPDATE_SCRIPT"

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

# Test the update script
echo "Testing update script..."
"$UPDATE_SCRIPT"

echo "Setup complete! Cursor will now check for updates nightly at midnight."
echo "You can also run '$UPDATE_SCRIPT' manually at any time to check for updates." 