#!/bin/bash

# Script to install the Cursor updater

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPDATE_SCRIPT="$SCRIPT_DIR/update_cursor.sh"
APPLY_UPDATE_SCRIPT="$SCRIPT_DIR/apply_pending_update.sh"
DESKTOP_ENTRY="$SCRIPT_DIR/cursor-updater.desktop"
LOCAL_BIN="$HOME/.local/bin"
AUTOSTART_DIR="$HOME/.config/autostart"

# Create directories if they don't exist
mkdir -p "$LOCAL_BIN" "$AUTOSTART_DIR" "$HOME/.local/share/cursor_update"

# Copy the update script to the local bin directory
echo "Installing update script to $LOCAL_BIN..."
cp "$UPDATE_SCRIPT" "$LOCAL_BIN/"
chmod +x "$LOCAL_BIN/update_cursor.sh"

# Copy the apply update script to the local bin directory
echo "Installing apply update script to $LOCAL_BIN..."
cp "$APPLY_UPDATE_SCRIPT" "$LOCAL_BIN/"
chmod +x "$LOCAL_BIN/apply_pending_update.sh"

# Copy the desktop entry to the autostart directory
echo "Setting up autostart..."
cp "$DESKTOP_ENTRY" "$AUTOSTART_DIR/"

# Update the desktop entry with the correct path
sed -i "s|\$HOME|$HOME|g" "$AUTOSTART_DIR/cursor-updater.desktop"

# Create a desktop entry for the apply update script
cat > "$AUTOSTART_DIR/cursor-apply-update.desktop" <<EOL
[Desktop Entry]
Type=Application
Name=Cursor Apply Update
Comment=Applies pending Cursor AI IDE updates
Exec=/bin/bash -c "sleep 30 && $HOME/.local/bin/apply_pending_update.sh"
Terminal=false
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOL

echo "Cursor updater installed successfully!"
echo "The updater will run automatically on system startup."
echo "You can also run it manually with: $LOCAL_BIN/update_cursor.sh"
echo "To apply pending updates, run: $LOCAL_BIN/apply_pending_update.sh"

# Run the updater once to check for updates
echo "Checking for updates now..."
"$LOCAL_BIN/update_cursor.sh" 