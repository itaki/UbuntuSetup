#!/bin/bash

# Script to apply pending Cursor updates
# This script checks if there's a pending update and applies it if Cursor is not running

# Define paths
LOCAL_BIN="$HOME/.local/bin"
APPIMAGE_PATH="$LOCAL_BIN/cursor.appimage"
PENDING_UPDATE="$HOME/.local/share/cursor_update/cursor.appimage.new"
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

# Check if there's a pending update
if [ ! -f "$PENDING_UPDATE" ]; then
    log "No pending updates found."
    exit 0
fi

# Check if Cursor is running
if pgrep -f "cursor" > /dev/null; then
    log "Cursor is currently running. Cannot apply update now."
    log "Please close Cursor and run this script again."
    exit 1
fi

# Get current version
CURRENT_VERSION=$(get_version "$APPIMAGE_PATH")
log "Current Cursor version: $CURRENT_VERSION"

# Get new version
chmod +x "$PENDING_UPDATE"
NEW_VERSION=$(get_version "$PENDING_UPDATE")
log "Pending update version: $NEW_VERSION"

# Compare versions (simple numeric comparison)
if [ -n "$CURRENT_VERSION" ] && [ -n "$NEW_VERSION" ]; then
    CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
    CURRENT_MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
    NEW_MAJOR=$(echo "$NEW_VERSION" | cut -d. -f1)
    NEW_MINOR=$(echo "$NEW_VERSION" | cut -d. -f2)
    
    if [ "$NEW_MAJOR" -lt "$CURRENT_MAJOR" ] || ([ "$NEW_MAJOR" -eq "$CURRENT_MAJOR" ] && [ "$NEW_MINOR" -lt "$CURRENT_MINOR" ]); then
        log "Warning: Pending update version ($NEW_VERSION) is older than current version ($CURRENT_VERSION). Aborting update."
        exit 1
    fi
    
    if [ "$NEW_MAJOR" -eq "$CURRENT_MAJOR" ] && [ "$NEW_MINOR" -eq "$CURRENT_MINOR" ]; then
        log "No update needed. Current version is already at $CURRENT_VERSION."
        rm "$PENDING_UPDATE"
        exit 0
    fi
elif [ -z "$CURRENT_VERSION" ] || [ -z "$NEW_VERSION" ]; then
    log "Warning: Could not determine version information. Proceeding with update based on file comparison only."
fi

log "Applying pending Cursor update from $CURRENT_VERSION to $NEW_VERSION..."

# Backup the current version
BACKUP_PATH="${APPIMAGE_PATH}.backup"
cp "$APPIMAGE_PATH" "$BACKUP_PATH"
log "Current version backed up to $BACKUP_PATH"

# Replace the current version with the new one
mv "$PENDING_UPDATE" "$APPIMAGE_PATH"
chmod +x "$APPIMAGE_PATH"
log "Cursor updated successfully!"

# Test if the new version works
if ! "$APPIMAGE_PATH" --no-sandbox --version &> /dev/null; then
    log "Warning: New version test failed. Restoring backup..."
    mv "$BACKUP_PATH" "$APPIMAGE_PATH"
    log "Backup restored."
    exit 1
else
    # Remove backup if test was successful
    rm "$BACKUP_PATH"
    log "Update verified and completed successfully."
fi

exit 0 