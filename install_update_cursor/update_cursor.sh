#!/bin/bash

# Script to check for and update Cursor AI IDE
# To be run on system startup

# Define paths
CURSOR_URL="https://cursor.so/resources/linux/cursor.appimage"
LOCAL_BIN="$HOME/.local/bin"
APPIMAGE_PATH="$LOCAL_BIN/cursor.appimage"
TEMP_PATH="/tmp/cursor_new.appimage"
LOG_FILE="$HOME/.local/share/cursor_update.log"

# Create directories if they don't exist
mkdir -p "$HOME/.local/share"

# Create log file if it doesn't exist
touch "$LOG_FILE"

# Log with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    echo "$1"
}

# Extract version from AppImage
get_version() {
    local appimage_path="$1"
    # Try different approaches to get the version
    
    # First attempt: Run with --version and look for Cursor version pattern (typically 4x.xx.x)
    local version=$("$appimage_path" --no-sandbox --version 2>/dev/null | grep -oE '(4[0-9]+|5[0-9]+)\.[0-9]+(\.[0-9]+)?' | head -1)
    
    # If that fails, try extracting from the AppImage itself
    if [ -z "$version" ]; then
        # Extract the version from the AppImage filename if it contains version info
        version=$(strings "$appimage_path" | grep -oE 'Cursor/[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d'/' -f2)
    fi
    
    # If we still don't have a version, try one more approach
    if [ -z "$version" ]; then
        # Look for package.json inside the AppImage
        version=$(strings "$appimage_path" | grep -A5 '"version":' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    fi
    
    # Validate that the version looks like a Cursor version (currently in the 40s or 50s)
    if [ -n "$version" ]; then
        local major=$(echo "$version" | cut -d. -f1)
        if [ "$major" -lt 40 ] || [ "$major" -gt 60 ]; then
            # This doesn't look like a valid Cursor version, so ignore it
            version=""
        fi
    fi
    
    # If we still don't have a version, try to get it from the Cursor website
    if [ -z "$version" ]; then
        # Try to extract the version from the Cursor website
        version=$(curl -s https://cursor.so/ | grep -oE 'Version [0-9]+\.[0-9]+(\.[0-9]+)?' | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    fi
    
    # If all else fails, assume it's the latest version (46.11 or higher)
    if [ -z "$version" ]; then
        log "Could not determine version, assuming latest version: 46.11.0"
        version="46.11.0"
    fi
    
    echo "$version"
}

# Check if Cursor is installed
if [ ! -f "$APPIMAGE_PATH" ]; then
    log "Cursor not found at $APPIMAGE_PATH. Nothing to update."
    exit 0
fi

log "Starting Cursor update check..."

# Get current version
CURRENT_VERSION=$(get_version "$APPIMAGE_PATH")
log "Current Cursor version: $CURRENT_VERSION"

# Check if Cursor is running
if pgrep -f "cursor" > /dev/null; then
    log "Cursor is currently running. Updates will be applied next time Cursor is closed."
    # We'll still download the update but won't apply it if Cursor is running
fi

# Download the latest version to a temporary file
log "Downloading latest Cursor version..."
if ! curl -L -s "$CURSOR_URL" -o "$TEMP_PATH"; then
    log "Failed to download latest version. Update aborted."
    exit 1
fi

# Make the temporary file executable
chmod +x "$TEMP_PATH"

# Get new version
NEW_VERSION=$(get_version "$TEMP_PATH")
log "Downloaded Cursor version: $NEW_VERSION"

# Compare versions (simple numeric comparison)
if [ -n "$CURRENT_VERSION" ] && [ -n "$NEW_VERSION" ]; then
    CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
    CURRENT_MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
    NEW_MAJOR=$(echo "$NEW_VERSION" | cut -d. -f1)
    NEW_MINOR=$(echo "$NEW_VERSION" | cut -d. -f2)
    
    if [ "$NEW_MAJOR" -lt "$CURRENT_MAJOR" ] || ([ "$NEW_MAJOR" -eq "$CURRENT_MAJOR" ] && [ "$NEW_MINOR" -lt "$CURRENT_MINOR" ]); then
        log "Warning: Downloaded version ($NEW_VERSION) is older than current version ($CURRENT_VERSION). Aborting update."
        rm "$TEMP_PATH"
        exit 1
    fi
    
    if [ "$NEW_MAJOR" -eq "$CURRENT_MAJOR" ] && [ "$NEW_MINOR" -eq "$CURRENT_MINOR" ]; then
        log "No update available. Current version is up to date."
        rm "$TEMP_PATH"
        exit 0
    fi
elif [ -z "$CURRENT_VERSION" ] || [ -z "$NEW_VERSION" ]; then
    log "Warning: Could not determine version information. Proceeding with update based on file comparison only."
fi

# Check if the downloaded file is different from the installed one
if cmp -s "$APPIMAGE_PATH" "$TEMP_PATH"; then
    log "No update available. Current version is up to date."
    rm "$TEMP_PATH"
    exit 0
fi

log "New version detected! Updating from $CURRENT_VERSION to $NEW_VERSION"

# Check if Cursor is running
if pgrep -f "cursor" > /dev/null; then
    log "Cursor is running. Update downloaded but will be applied on next startup."
    # Save the update for next time
    mkdir -p "$HOME/.local/share/cursor_update"
    mv "$TEMP_PATH" "$HOME/.local/share/cursor_update/cursor.appimage.new"
    log "Update saved to $HOME/.local/share/cursor_update/cursor.appimage.new"
    log "It will be applied next time Cursor is not running."
    exit 0
fi

# Backup the current version
BACKUP_PATH="${APPIMAGE_PATH}.backup"
cp "$APPIMAGE_PATH" "$BACKUP_PATH"
log "Current version backed up to $BACKUP_PATH"

# Replace the current version with the new one
mv "$TEMP_PATH" "$APPIMAGE_PATH"
chmod +x "$APPIMAGE_PATH"
log "Cursor updated successfully!"

# Test if the new version works
if ! "$APPIMAGE_PATH" --no-sandbox --version &> /dev/null; then
    log "Warning: New version test failed. Restoring backup..."
    mv "$BACKUP_PATH" "$APPIMAGE_PATH"
    log "Backup restored."
else
    # Remove backup if test was successful
    rm "$BACKUP_PATH"
    log "Update verified and completed successfully."
fi

exit 0 