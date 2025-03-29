#!/bin/bash

# Script to check for and update Cursor AI IDE
# To be run on system startup and nightly via cron

# Define paths and URLs
VERSION_HISTORY_URL="https://raw.githubusercontent.com/oslook/cursor-ai-downloads/main/version-history.json"
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

# Function to get the latest version and download URL from GitHub repository
get_latest_version() {
    log "Checking online repository for latest version..."
    
    # Download the JSON content
    local json_content=$(curl -s "$VERSION_HISTORY_URL")
    
    # Save JSON for inspection
    echo "$json_content" > "/tmp/cursor_version_info.json"
    
    # Extract the latest version number
    local latest_version=$(echo "$json_content" | grep -o '"version": "[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$latest_version" ]; then
        log "ERROR: Could not determine latest version from GitHub repository."
        echo "Check the JSON file at /tmp/cursor_version_info.json"
        return 1
    fi
    
    # Extract download link for Linux x64 - looking for the complete URL with hash
    local download_link=$(echo "$json_content" | tr -d '\n' | sed -n '/"linux-x64":/,/}/ p' | grep -o 'https://[^"]*x86_64.AppImage' | head -1)
    
    if [ -z "$download_link" ]; then
        log "ERROR: Could not find download link for version $latest_version"
        echo "Check the JSON file at /tmp/cursor_version_info.json"
        return 1
    fi
    
    # Save the download link to a temporary file
    echo "$download_link" > "/tmp/cursor_download_url.txt"
    
    # Output the version for the main script
    echo "$latest_version"
}

# Function to get current version
get_current_version() {
    if [ ! -f "$APPIMAGE_PATH" ]; then
        echo "not_installed"
        return
    fi
    
    local version=$("$APPIMAGE_PATH" --version 2>/dev/null)
    if [ -z "$version" ]; then
        echo "unknown"
        return
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
CURRENT_VERSION=$(get_current_version)
log "Current Cursor version: $CURRENT_VERSION"

# Check online repository for latest version
if get_latest_version; then
    LATEST_VERSION=$(get_latest_version | tail -1)
    log "Latest version: $LATEST_VERSION"
    
    # Read the download URL from the temporary file
    if [ -f "/tmp/cursor_download_url.txt" ]; then
        CURSOR_URL=$(cat "/tmp/cursor_download_url.txt")
        log "Download URL: $CURSOR_URL"
    else
        log "ERROR: Download URL not found in temporary file."
        exit 1
    fi
else
    log "Failed to get latest version from online repository."
    log "Checking for local AppImage..."
    
    # Look for a recent AppImage in Downloads directory
    RECENT_APPIMAGE=$(find "$HOME/Downloads" -type f \( -name "cursor*.appimage" -o -name "Cursor*.AppImage" -o -name "cursor*.AppImage" -o -name "Cursor*.appimage" -o -name "Cursor-*.appimage" -o -name "Cursor-*.AppImage" -o -name "Cursor-*-x86_64.appimage" -o -name "Cursor-*-x86_64.AppImage" \) -mtime -30 2>/dev/null | head -1)
    
    if [ -n "$RECENT_APPIMAGE" ]; then
        log "Found recent AppImage: $RECENT_APPIMAGE"
        CURSOR_URL="$RECENT_APPIMAGE"
    else
        log "No recent AppImage found in Downloads directory."
        exit 1
    fi
fi

# Check if update is needed
if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
    log "No update needed. Current version is up to date."
    exit 0
fi

# Check if Cursor is running
if pgrep -f "cursor" > /dev/null; then
    log "Cursor is currently running. Updates will be applied next time Cursor is closed."
    # We'll still download the update but won't apply it if Cursor is running
fi

# Download the latest version to a temporary file
log "Downloading latest Cursor version..."
if [ -f "$CURSOR_URL" ]; then
    # If CURSOR_URL is a local file, copy it
    cp "$CURSOR_URL" "$TEMP_PATH"
else
    # Otherwise download it
    curl -L "$CURSOR_URL" -o "$TEMP_PATH"
fi

if [ $? -ne 0 ]; then
    log "Failed to download Cursor."
    exit 1
fi

# Make the temporary file executable
chmod +x "$TEMP_PATH"

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