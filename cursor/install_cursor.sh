#!/bin/bash

# Cursor Installation Script
# This script installs Cursor AI IDE

# Define paths and URLs
VERSION_HISTORY_URL="https://raw.githubusercontent.com/oslook/cursor-ai-downloads/main/version-history.json"
ICON_URL="https://miro.medium.com/v2/resize:fit:700/1*YLg8VpqXaTyRHJoStnMuog.png"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_APPS="$HOME/.local/share/applications"
LOCAL_ICONS="$HOME/.local/share/icons"
APPIMAGE_PATH="$LOCAL_BIN/cursor.appimage"
ICON_PATH="$LOCAL_ICONS/cursor.png"
DESKTOP_ENTRY_PATH="$LOCAL_APPS/cursor.desktop"
IS_NEW_INSTALL=false

# Create necessary directories
mkdir -p "$LOCAL_BIN" "$LOCAL_APPS" "$LOCAL_ICONS"

# Function to get the latest version and download URL from GitHub repository
get_latest_version() {
    echo "Checking online repository for latest version..."
    
    # GitHub repository with official download links
    VERSION_HISTORY_URL="https://raw.githubusercontent.com/oslook/cursor-ai-downloads/main/version-history.json"
    
    # Download the JSON content
    local json_content=$(curl -s "$VERSION_HISTORY_URL")
    
    # Save JSON for inspection
    echo "$json_content" > "/tmp/cursor_version_info.json"
    
    # Extract the latest version number
    local latest_version=$(echo "$json_content" | grep -o '"version": "[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -z "$latest_version" ]; then
        echo "ERROR: Could not determine latest version from GitHub repository."
        echo "Check the JSON file at /tmp/cursor_version_info.json"
        return 1
    fi
    
    # Extract download link for Linux x64 - looking for the complete URL with hash
    local download_link=$(echo "$json_content" | tr -d '\n' | sed -n '/"linux-x64":/,/}/ p' | grep -o 'https://[^"]*x86_64.AppImage' | head -1)
    
    if [ -z "$download_link" ]; then
        echo "ERROR: Could not find download link for version $latest_version"
        echo "Check the JSON file at /tmp/cursor_version_info.json"
        return 1
    fi
    
    # Save the download link to a temporary file
    echo "$download_link" > "/tmp/cursor_download_url.txt"
    
    # Output the version for the main script
    echo "$latest_version"
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    # Check for libfuse2
    if ! ldconfig -p | grep -q libfuse.so.2; then
        missing_deps+=("libfuse2")
    fi
    
    # Install missing dependencies
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "Missing dependencies: ${missing_deps[*]}"
        read -p "Would you like to install the missing dependencies? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Installing missing dependencies: ${missing_deps[*]}"
            sudo apt-get update
            sudo apt-get install -y "${missing_deps[@]}" || {
                echo "Failed to install dependencies."
                exit 1
            }
        else
            echo "Dependencies are required for Cursor to work properly."
            exit 1
        fi
    fi

    # Verify FUSE setup
    if [ ! -e /dev/fuse ]; then
        echo "FUSE device not found. Creating..."
        sudo mknod -m 666 /dev/fuse c 10 229
    fi

    # Make sure FUSE has correct permissions
    sudo chmod 666 /dev/fuse

    # Add current user to fuse group if it exists
    if getent group fuse > /dev/null; then
        if ! groups | grep -q fuse; then
            sudo usermod -a -G fuse "$USER"
            echo "Added user to fuse group. You may need to log out and back in for this to take effect."
        fi
    fi
}

# Function to kill Cursor processes
kill_cursor_processes() {
    if pgrep -f "cursor" > /dev/null; then
        echo "Killing all Cursor processes..."
        
        # Get the PID of this script to avoid killing itself
        local SCRIPT_PID=$$
        local PARENT_PID=$PPID
        
        echo "Preserving user preferences and settings during installation..."
        
        # First try to kill main processes, excluding this script
        pkill -f "/tmp/.mount_cursor.*/cursor --no-sandbox" 2>/dev/null
        pkill -f "cursor.appimage --no-sandbox" 2>/dev/null
        sleep 2
        
        # If processes are still running, kill them individually
        local cursor_processes=$(ps aux | grep -E '(/cursor|cursor.appimage)' | grep -v "grep" | grep -v "install_cursor.sh" | grep -v "$SCRIPT_PID" | grep -v "$PARENT_PID" | awk '{print $2}')
        if [ -n "$cursor_processes" ]; then
            for pid in $cursor_processes; do
                # Double check that we're not killing ourselves
                if [ "$pid" != "$SCRIPT_PID" ] && [ "$pid" != "$PARENT_PID" ]; then
                    echo "Closing Cursor process: $pid"
                    kill $pid 2>/dev/null
                fi
            done
            sleep 2
        fi
        
        # Force kill if necessary, but be careful not to kill this script
        if pgrep -f "cursor" | grep -v "$SCRIPT_PID" | grep -v "$PARENT_PID" > /dev/null; then
            echo "Some processes are stubborn. Using force kill..."
            for pid in $(pgrep -f "/tmp/.mount_cursor" | grep -v "$SCRIPT_PID" | grep -v "$PARENT_PID"); do
                if [ -n "$pid" ]; then
                    echo "Force closing Cursor process: $pid"
                    kill -9 $pid 2>/dev/null
                fi
            done
            
            for pid in $(pgrep -f "cursor.appimage" | grep -v "$SCRIPT_PID" | grep -v "$PARENT_PID"); do
                if [ -n "$pid" ]; then
                    echo "Force closing Cursor process: $pid"
                    kill -9 $pid 2>/dev/null
                fi
            done
            sleep 1
        fi
        
        # Check if all processes are killed
        if pgrep -f "cursor" | grep -v "$SCRIPT_PID" | grep -v "$PARENT_PID" | grep -v "install_cursor.sh" > /dev/null; then
            echo "Warning: Some Cursor processes could not be terminated."
            echo "This might affect the installation. Consider closing them manually."
        else
            echo "All Cursor processes successfully terminated."
        fi
    else
        echo "No Cursor processes found running."
    fi
}

# Function to install Cursor
install_cursor() {
    # Ensure user preferences are preserved
    echo "Note: This installation preserves all user preferences, extensions, and settings."
    
    # Create backup if updating
    if [ "$IS_NEW_INSTALL" = false ] && [ -f "$APPIMAGE_PATH" ]; then
        echo "Creating backup of current installation..."
        cp "$APPIMAGE_PATH" "${APPIMAGE_PATH}.backup"
    fi
    
    # Download and install Cursor
    echo "Downloading Cursor..."
    curl -L "$CURSOR_URL" -o "$APPIMAGE_PATH" || {
        echo "Failed to download Cursor. Please check your internet connection."
        if [ -f "${APPIMAGE_PATH}.backup" ]; then
            echo "Restoring from backup..."
            mv "${APPIMAGE_PATH}.backup" "$APPIMAGE_PATH"
            echo "Restored previous version."
        fi
        exit 1
    }
    
    chmod +x "$APPIMAGE_PATH"
    
    # Remove backup if installation was successful
    if [ -f "${APPIMAGE_PATH}.backup" ]; then
        rm "${APPIMAGE_PATH}.backup"
    fi
    
    echo "Cursor installed successfully!"
    echo "All user preferences, extensions, and settings have been preserved."
}

# Function to setup new installation
setup_new_installation() {
    # Create desktop entry
    read -p "Would you like to create a desktop entry for Cursor? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Download icon
        echo "Downloading Cursor icon..."
        curl -L "$ICON_URL" -o /tmp/cursor.png || {
            echo "Failed to download icon. Using default icon."
        }
        
        if [ -f "/tmp/cursor.png" ]; then
            mv /tmp/cursor.png "$ICON_PATH"
        fi
        
        # Create desktop entry
        echo "Creating desktop entry..."
        cat > "$DESKTOP_ENTRY_PATH" <<EOL
[Desktop Entry]
Version=1.0
Name=Cursor AI IDE
Comment=AI-powered code editor
Exec=$APPIMAGE_PATH %F
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Development;TextEditor;IDE;
MimeType=text/plain;inode/directory;
StartupWMClass=Cursor
StartupNotify=true
EOL

        chmod +x "$DESKTOP_ENTRY_PATH"
        
        # Update desktop database
        update-desktop-database "$LOCAL_APPS" 2>/dev/null || true
        
        echo "Desktop entry created successfully."
    else
        echo "Skipping desktop entry creation."
    fi
}

# Main script
echo "=== Cursor AI IDE Installer ==="

# INFORMATION SECTION
echo "=== Information Section ==="

# Check if Cursor is installed
if [ ! -f "$APPIMAGE_PATH" ]; then
    IS_NEW_INSTALL=true
    echo "Cursor is not installed."
else
    echo "Cursor is installed."
fi

# Check online repository for latest version
if get_latest_version; then
    LATEST_VERSION=$(get_latest_version | tail -1)
    echo "Latest version: $LATEST_VERSION"
    
    # Read the download URL from the temporary file
    if [ -f "/tmp/cursor_download_url.txt" ]; then
        CURSOR_URL=$(cat "/tmp/cursor_download_url.txt")
        echo "Download URL: $CURSOR_URL"
    else
        echo "ERROR: Download URL not found in temporary file."
        exit 1
    fi
else
    echo "Failed to get latest version from online repository."
    echo "Checking for local AppImage..."
    
    # Look for a recent AppImage in Downloads directory
    RECENT_APPIMAGE=$(find "$HOME/Downloads" -type f \( -name "cursor*.appimage" -o -name "Cursor*.AppImage" -o -name "cursor*.AppImage" -o -name "Cursor*.appimage" -o -name "Cursor-*.appimage" -o -name "Cursor-*.AppImage" -o -name "Cursor-*-x86_64.appimage" -o -name "Cursor-*-x86_64.AppImage" \) -mtime -30 2>/dev/null | head -1)
    
    if [ -n "$RECENT_APPIMAGE" ]; then
        echo "Found recent AppImage: $RECENT_APPIMAGE"
        # Extract version from filename
        LATEST_VERSION=$(basename "$RECENT_APPIMAGE" | grep -oP 'Cursor-(\d+\.\d+\.\d+)' | cut -d'-' -f2)
        CURSOR_URL="$RECENT_APPIMAGE"
    else
        echo "No recent AppImage found in Downloads directory."
        echo "Please run this script again when you have internet connectivity."
        exit 1
    fi
fi

# INSTALL SECTION
echo
echo "=== Install Section ==="

# Always ask if user wants to install/update
if [ "$IS_NEW_INSTALL" = true ]; then
    read -p "Would you like to install Cursor version $LATEST_VERSION? (y/n) " -n 1 -r
else
    read -p "Would you like to update to version $LATEST_VERSION? (y/n) " -n 1 -r
fi
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Kill all running Cursor processes
kill_cursor_processes

# Download the AppImage
echo "Downloading Cursor version $LATEST_VERSION..."
if [ -f "$CURSOR_URL" ]; then
    # If CURSOR_URL is a local file, copy it
    cp "$CURSOR_URL" "$APPIMAGE_PATH"
else
    # Otherwise download it
    curl -L "$CURSOR_URL" -o "$APPIMAGE_PATH"
fi

if [ $? -ne 0 ]; then
    echo "Failed to download Cursor."
    exit 1
fi

# Make the AppImage executable
chmod +x "$APPIMAGE_PATH"

# NEW INSTALL SECTION (if applicable)
if [ "$IS_NEW_INSTALL" = true ]; then
    echo
    echo "=== New Install Section ==="
    
    # Check dependencies
    check_dependencies
    
    # Setup new installation (desktop entry)
    setup_new_installation
fi

# EXIT SECTION
echo
echo "=== Installation Complete ==="

# Provide info about what the script did
if [ "$IS_NEW_INSTALL" = true ]; then
    echo "New install of Cursor completed successfully."
    if [ -f "$DESKTOP_ENTRY_PATH" ]; then
        echo "Created a desktop entry for easy access."
    fi
else
    echo "Cursor has been updated successfully."
fi

# Always offer to launch Cursor
echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Would you like to open Cursor now? (y/n):${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Launching Cursor...${NC}"
    "$APPIMAGE_PATH" --no-sandbox &
fi

exit 0