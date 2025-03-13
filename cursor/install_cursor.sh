#!/bin/bash

# Cursor Installation Script
# This script checks for, downloads, and installs the latest version of Cursor AI IDE

# Define paths and URLs
CURSOR_URL="https://cursor.so/resources/linux/cursor.appimage"
ICON_URL="https://miro.medium.com/v2/resize:fit:700/1*YLg8VpqXaTyRHJoStnMuog.png"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_APPS="$HOME/.local/share/applications"
LOCAL_ICONS="$HOME/.local/share/icons"
APPIMAGE_PATH="$LOCAL_BIN/cursor.appimage"
ICON_PATH="$LOCAL_ICONS/cursor.png"
DESKTOP_ENTRY_PATH="$LOCAL_APPS/cursor.desktop"
DOWNLOAD_APPIMAGE_PATH=""
IS_NEW_INSTALL=false

# Create necessary directories
mkdir -p "$LOCAL_BIN" "$LOCAL_APPS" "$LOCAL_ICONS"

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
        echo "Installing missing dependencies: ${missing_deps[*]}"
        sudo apt-get update
        sudo apt-get install -y "${missing_deps[@]}" || {
            echo "Failed to install dependencies."
            exit 1
        }
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

# Function to get current version
get_current_version() {
    if [ ! -f "$APPIMAGE_PATH" ]; then
        echo "Cursor is not currently installed."
        IS_NEW_INSTALL=true
        return 1
    fi
    
    # Try to get version from AppImage
    local version=""
    
    # Method 1: Run with --version flag
    version=$("$APPIMAGE_PATH" --no-sandbox --version 2>/dev/null | grep -oE '(4[0-9]+|5[0-9]+)\.[0-9]+(\.[0-9]+)?' | head -1)
    
    # Method 2: Extract from AppImage strings
    if [ -z "$version" ]; then
        version=$(strings "$APPIMAGE_PATH" | grep -oE 'Cursor/[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d'/' -f2)
    fi
    
    # Method 3: Look for version in package.json
    if [ -z "$version" ]; then
        version=$(strings "$APPIMAGE_PATH" | grep -A5 '"version":' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    fi
    
    # Validate version format
    if [ -n "$version" ]; then
        local major=$(echo "$version" | cut -d. -f1)
        if [ "$major" -lt 40 ] || [ "$major" -gt 60 ]; then
            echo "Unknown version detected."
            return 1
        fi
        echo "Current Cursor version: $version"
        echo "$version"
        return 0
    else
        echo "Could not determine current version."
        return 1
    fi
}

# Function to get latest version
get_latest_version() {
    # Try to get version from Cursor website
    local version=$(curl -s https://cursor.so/ | grep -oE 'Version [0-9]+\.[0-9]+(\.[0-9]+)?' | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    
    # Try downloads page if website fails
    if [ -z "$version" ]; then
        version=$(curl -s https://www.cursor.com/downloads | grep -oE 'Version \([0-9]+\.[0-9]+\)' | grep -oE '[0-9]+\.[0-9]+' | head -1)
    fi
    
    # Use downloads directory if all else fails
    if [ -z "$version" ]; then
        echo "I can't find an online version of Cursor."
        read -p "Look in Downloads directory instead? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Checking Downloads directory for Cursor AppImages..."
            local downloads_dir="$HOME/Downloads"
            if [ -d "$downloads_dir" ]; then
                # Find all cursor AppImages in Downloads directory
                local cursor_files=$(find "$downloads_dir" -name "cursor*.appimage" -o -name "Cursor*.AppImage" -o -name "cursor*.AppImage" -o -name "Cursor*.appimage" 2>/dev/null)
                
                if [ -z "$cursor_files" ]; then
                    echo "No Cursor AppImages found in Downloads directory."
                    exit 1
                fi
                
                # Extract version from each file and find the highest
                local highest_version=""
                local highest_file=""
                
                for file in $cursor_files; do
                    echo "Found: $(basename "$file")"
                    local file_version=""
                    
                    # Try to extract version from filename
                    file_version=$(basename "$file" | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
                    
                    # If no version in filename, try to extract from file content
                    if [ -z "$file_version" ]; then
                        file_version=$(strings "$file" | grep -oE 'Cursor/[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d'/' -f2)
                    fi
                    
                    if [ -n "$file_version" ]; then
                        echo "  Version: $file_version"
                        
                        # Compare versions to find highest
                        if [ -z "$highest_version" ]; then
                            highest_version="$file_version"
                            highest_file="$file"
                        else
                            local current_major=$(echo "$highest_version" | cut -d. -f1)
                            local current_minor=$(echo "$highest_version" | cut -d. -f2)
                            local file_major=$(echo "$file_version" | cut -d. -f1)
                            local file_minor=$(echo "$file_version" | cut -d. -f2)
                            
                            if [ "$file_major" -gt "$current_major" ] || ([ "$file_major" -eq "$current_major" ] && [ "$file_minor" -gt "$current_minor" ]); then
                                highest_version="$file_version"
                                highest_file="$file"
                            fi
                        fi
                    fi
                done
                
                if [ -n "$highest_version" ]; then
                    echo "Using highest version found: $highest_version (from $(basename "$highest_file"))"
                    # Save the path to use during installation
                    DOWNLOAD_APPIMAGE_PATH="$highest_file"
                    version="$highest_version"
                else
                    echo "Could not determine version from any of the found files."
                    exit 1
                fi
            else
                echo "Downloads directory not found."
                exit 1
            fi
        else
            echo "Exiting as requested."
            exit 0
        fi
    fi
    
    echo "Latest Cursor version: $version"
    echo "$version"
}

# Function to compare versions
compare_versions() {
    local current_version="$1"
    local latest_version="$2"
    
    if [ -z "$current_version" ]; then
        return 0  # No current version, need to install
    fi
    
    local current_major=$(echo "$current_version" | cut -d. -f1)
    local current_minor=$(echo "$current_version" | cut -d. -f2)
    local latest_major=$(echo "$latest_version" | cut -d. -f1)
    local latest_minor=$(echo "$latest_version" | cut -d. -f2)
    
    if [ "$latest_major" -gt "$current_major" ] || ([ "$latest_major" -eq "$current_major" ] && [ "$latest_minor" -gt "$current_minor" ]); then
        echo "A newer version is available."
        return 0  # Update needed
    else
        echo "You already have the latest version."
        return 1  # No update needed
    fi
}

# Function to kill Cursor processes
kill_cursor_processes() {
    if pgrep -f "cursor" > /dev/null; then
        echo "Killing all Cursor processes..."
        
        # First try to kill main processes
        pkill -f "/tmp/.mount_cursor.*/cursor --no-sandbox" 2>/dev/null
        pkill -f "cursor.appimage --no-sandbox" 2>/dev/null
        sleep 2
        
        # If processes are still running, kill them individually
        local cursor_processes=$(ps aux | grep -E '(/cursor|cursor.appimage)' | grep -v "grep" | grep -v "install_cursor.sh" | awk '{print $2}')
        if [ -n "$cursor_processes" ]; then
            for pid in $cursor_processes; do
                kill $pid 2>/dev/null
            done
            sleep 2
        fi
        
        # Force kill if necessary
        if pgrep -f "cursor" > /dev/null; then
            echo "Some processes are stubborn. Using force kill..."
            pkill -9 -f "/tmp/.mount_cursor" 2>/dev/null
            pkill -9 -f "cursor.appimage" 2>/dev/null
            sleep 1
        fi
        
        # Check if all processes are killed
        if pgrep -f "cursor" > /dev/null; then
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
    # If we have a downloaded AppImage from the Downloads directory, use it
    if [ -n "$DOWNLOAD_APPIMAGE_PATH" ] && [ -f "$DOWNLOAD_APPIMAGE_PATH" ]; then
        echo "Using Cursor AppImage from Downloads directory..."
        
        # Create backup if updating
        if [ "$IS_NEW_INSTALL" = false ] && [ -f "$APPIMAGE_PATH" ]; then
            echo "Creating backup of current installation..."
            cp "$APPIMAGE_PATH" "${APPIMAGE_PATH}.backup"
        fi
        
        # Install from the downloaded file
        echo "Installing Cursor..."
        cp "$DOWNLOAD_APPIMAGE_PATH" "$APPIMAGE_PATH"
        chmod +x "$APPIMAGE_PATH"
    else
        # Download from the internet
        echo "Downloading latest Cursor version..."
        curl -L "$CURSOR_URL" -o /tmp/cursor.appimage || {
            echo "Failed to download Cursor. Please check your internet connection."
            exit 1
        }
        
        # Make the downloaded file executable
        chmod +x /tmp/cursor.appimage
        
        # Create backup if updating
        if [ "$IS_NEW_INSTALL" = false ] && [ -f "$APPIMAGE_PATH" ]; then
            echo "Creating backup of current installation..."
            cp "$APPIMAGE_PATH" "${APPIMAGE_PATH}.backup"
        fi
        
        # Install the new version
        echo "Installing Cursor..."
        mv /tmp/cursor.appimage "$APPIMAGE_PATH"
        chmod +x "$APPIMAGE_PATH"
    fi
    
    # Test the installation
    if ! "$APPIMAGE_PATH" --no-sandbox --version &> /dev/null; then
        echo "Installation test failed."
        if [ -f "${APPIMAGE_PATH}.backup" ]; then
            echo "Restoring from backup..."
            mv "${APPIMAGE_PATH}.backup" "$APPIMAGE_PATH"
            echo "Restored previous version."
        fi
        exit 1
    fi
    
    # Remove backup if test was successful
    if [ -f "${APPIMAGE_PATH}.backup" ]; then
        rm "${APPIMAGE_PATH}.backup"
    fi
    
    echo "Cursor installed successfully!"
}

# Function to set up new installation
setup_new_installation() {
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
Exec=$APPIMAGE_PATH --no-sandbox %F
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
    
    # Add shell alias
    setup_shell_alias
}

# Function to set up shell alias
setup_shell_alias() {
    local SHELL_NAME=$(basename "$SHELL")
    local RC_FILE=""
    
    case "$SHELL_NAME" in
        bash)
            RC_FILE="$HOME/.bashrc"
            ;;
        zsh)
            RC_FILE="$HOME/.zshrc"
            ;;
        fish)
            RC_FILE="$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "Unsupported shell: $SHELL_NAME"
            echo "Please manually add an alias for Cursor."
            return
            ;;
    esac
    
    if [ -n "$RC_FILE" ]; then
        if [ "$SHELL_NAME" = "fish" ]; then
            if ! grep -q "function cursor" "$RC_FILE"; then
                echo "Adding cursor function to $RC_FILE..."
                cat >> "$RC_FILE" <<EOL

# Cursor function
function cursor
    $APPIMAGE_PATH --no-sandbox \$argv > /dev/null 2>&1 & disown
end
EOL
            fi
        else
            if ! grep -q "function cursor" "$RC_FILE"; then
                echo "Adding cursor function to $RC_FILE..."
                cat >> "$RC_FILE" <<EOL

# Cursor function
function cursor() {
    $APPIMAGE_PATH --no-sandbox "\$@" > /dev/null 2>&1 & disown
}
EOL
            fi
        fi
        
        echo "Shell alias added. You can now use 'cursor' command in terminal."
        echo "To activate the alias in this session, run: source $RC_FILE"
    fi
}

# Function to show exit options
show_exit_options() {
    echo
    echo "Cursor AI IDE is ready to use!"
    echo "You can find it in your application menu or run it from terminal with 'cursor' command."
    echo
    read -p "Would you like to open Cursor now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Starting Cursor..."
        "$APPIMAGE_PATH" --no-sandbox &
    else
        echo "You can start Cursor later from your application menu or by typing 'cursor' in terminal."
    fi
}

# Main script execution starts here

echo "=== Cursor AI IDE Installer ==="
echo

# Check dependencies
check_dependencies

# Information section
echo "=== Checking Versions ==="
CURRENT_VERSION=$(get_current_version)
LATEST_VERSION=$(get_latest_version)

if compare_versions "$CURRENT_VERSION" "$LATEST_VERSION"; then
    # Install section
    echo
    echo "=== Installing Cursor ==="
    
    # Kill any running Cursor processes
    kill_cursor_processes
    
    # Install Cursor
    install_cursor
    
    # New install section (if applicable)
    if [ "$IS_NEW_INSTALL" = true ]; then
        echo
        echo "=== Setting Up New Installation ==="
        setup_new_installation
    fi
    
    # Exit section
    echo
    echo "=== Installation Complete ==="
    show_exit_options
else
    # Exit section (no update needed)
    echo
    echo "=== No Update Required ==="
    show_exit_options
fi

exit 0