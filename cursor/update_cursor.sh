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

# Function to kill Cursor processes
kill_cursor_processes() {
    if pgrep -f "cursor" > /dev/null; then
        log "Killing all Cursor processes..."
        
        # Get the PID of this script to avoid killing itself
        local SCRIPT_PID=$$
        local PARENT_PID=$PPID
        
        # First try to kill main processes, excluding this script
        pkill -f "/tmp/.mount_cursor.*/cursor --no-sandbox" 2>/dev/null
        pkill -f "cursor.appimage --no-sandbox" 2>/dev/null
        sleep 2
        
        # If processes are still running, kill them individually
        local cursor_processes=$(ps aux | grep -E '(/cursor|cursor.appimage)' | grep -v "grep" | grep -v "update_cursor.sh" | grep -v "$SCRIPT_PID" | grep -v "$PARENT_PID" | awk '{print $2}')
        if [ -n "$cursor_processes" ]; then
            for pid in $cursor_processes; do
                if [ "$pid" != "$SCRIPT_PID" ] && [ "$pid" != "$PARENT_PID" ]; then
                    log "Closing Cursor process: $pid"
                    kill $pid 2>/dev/null
                fi
            done
            sleep 2
        fi
        
        # Force kill if necessary, but be careful not to kill this script
        if pgrep -f "cursor" | grep -v "$SCRIPT_PID" | grep -v "$PARENT_PID" > /dev/null; then
            log "Some processes are stubborn. Using force kill..."
            for pid in $(pgrep -f "/tmp/.mount_cursor" | grep -v "$SCRIPT_PID" | grep -v "$PARENT_PID"); do
                if [ -n "$pid" ]; then
                    log "Force closing Cursor process: $pid"
                    kill -9 $pid 2>/dev/null
                fi
            done
            
            for pid in $(pgrep -f "cursor.appimage" | grep -v "$SCRIPT_PID" | grep -v "$PARENT_PID"); do
                if [ -n "$pid" ]; then
                    log "Force closing Cursor process: $pid"
                    kill -9 $pid 2>/dev/null
                fi
            done
            sleep 1
        fi
    fi
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

# Kill all running Cursor processes
kill_cursor_processes

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