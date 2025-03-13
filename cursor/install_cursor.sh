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
    
    # Check if Cursor is running and get version from process
    local version=""
    
    # Method: Check running processes for version information
    version=$(ps aux | grep -i cursor | grep -v grep | grep -i version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    # If no running process, try to start Cursor with --version flag
    if [ -z "$version" ]; then
        echo "No running Cursor process found. Trying to check version directly..."
        version=$("$APPIMAGE_PATH" --no-sandbox --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    fi
    
    # Validate version format
    if [ -n "$version" ]; then
        echo "Current Cursor version: $version"
        echo "$version"
        return 0
    else
        echo "Could not determine current version."
        # If we can't determine the version but the file exists, we'll assume it's installed
        # but we don't know the version
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
    
    # Use downloads directory or repository if all else fails
    if [ -z "$version" ]; then
        echo "I can't find an online version of Cursor."
        read -p "Look in Downloads directory or repository instead? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # First check the repository (current directory and parent directories)
            echo "Checking repository for Cursor AppImages..."
            local repo_cursor_files=$(find "$(pwd)" -maxdepth 3 -name "Cursor-*.appimage" -o -name "Cursor-*.AppImage" 2>/dev/null)
            
            # Then check Downloads directory
            echo "Checking Downloads directory for Cursor AppImages..."
            local downloads_dir="$HOME/Downloads"
            local downloads_cursor_files=""
            if [ -d "$downloads_dir" ]; then
                downloads_cursor_files=$(find "$downloads_dir" -name "cursor*.appimage" -o -name "Cursor*.AppImage" -o -name "cursor*.AppImage" -o -name "Cursor*.appimage" -o -name "Cursor-*.appimage" -o -name "Cursor-*.AppImage" -o -name "Cursor-*-x86_64.appimage" 2>/dev/null)
            fi
            
            # Combine results
            local cursor_files="$repo_cursor_files $downloads_cursor_files"
            
            if [ -z "$cursor_files" ]; then
                echo "No Cursor AppImages found in repository or Downloads directory."
                exit 1
            fi
            
            # Extract version from each file and find the highest
            local highest_version=""
            local highest_file=""
            
            for file in $cursor_files; do
                echo "Found: $(basename "$file")"
                local file_version=""
                
                # Try to extract version from filename (Cursor-0.46.11-ae378be9dc2f5f1a6a1a220c6e25f9f03c8d4e19.deb.glibc2.25-x86_64.appimage)
                file_version=$(basename "$file" | grep -oE 'Cursor-[0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                
                # Try alternative filename pattern
                if [ -z "$file_version" ]; then
                    file_version=$(basename "$file" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                fi
                
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
                        local current_patch=$(echo "$highest_version" | cut -d. -f3 | grep -oE '[0-9]+' | head -1)
                        local file_major=$(echo "$file_version" | cut -d. -f1)
                        local file_minor=$(echo "$file_version" | cut -d. -f2)
                        local file_patch=$(echo "$file_version" | cut -d. -f3 | grep -oE '[0-9]+' | head -1)
                        
                        # Compare major version
                        if [ "$file_major" -gt "$current_major" ]; then
                            highest_version="$file_version"
                            highest_file="$file"
                        # If major versions are equal, compare minor versions
                        elif [ "$file_major" -eq "$current_major" ] && [ "$file_minor" -gt "$current_minor" ]; then
                            highest_version="$file_version"
                            highest_file="$file"
                        # If major and minor versions are equal, compare patch versions
                        elif [ "$file_major" -eq "$current_major" ] && [ "$file_minor" -eq "$current_minor" ] && [ -n "$file_patch" ] && [ -n "$current_patch" ] && [ "$file_patch" -gt "$current_patch" ]; then
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
    local current_patch=$(echo "$current_version" | cut -d. -f3 | grep -oE '[0-9]+' | head -1)
    local latest_major=$(echo "$latest_version" | cut -d. -f1)
    local latest_minor=$(echo "$latest_version" | cut -d. -f2)
    local latest_patch=$(echo "$latest_version" | cut -d. -f3 | grep -oE '[0-9]+' | head -1)
    
    # Compare major version
    if [ "$latest_major" -gt "$current_major" ]; then
        echo "A newer version is available."
        return 0  # Update needed
    # If major versions are equal, compare minor versions
    elif [ "$latest_major" -eq "$current_major" ] && [ "$latest_minor" -gt "$current_minor" ]; then
        echo "A newer version is available."
        return 0  # Update needed
    # If major and minor versions are equal, compare patch versions if available
    elif [ "$latest_major" -eq "$current_major" ] && [ "$latest_minor" -eq "$current_minor" ] && [ -n "$latest_patch" ] && [ -n "$current_patch" ] && [ "$latest_patch" -gt "$current_patch" ]; then
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
    echo "All user preferences, extensions, and settings have been preserved."
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

# Checkpoint 1: Confirm installation or update
if [ "$IS_NEW_INSTALL" = true ]; then
    echo
    echo "This is a new installation of Cursor."
    read -p "Install Cursor version $LATEST_VERSION? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
else
    echo
    echo "Cursor version $CURRENT_VERSION is currently installed."
    if compare_versions "$CURRENT_VERSION" "$LATEST_VERSION"; then
        read -p "Update to Cursor version $LATEST_VERSION? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Update cancelled."
            exit 0
        fi
    else
        echo "You already have the latest version."
        read -p "Would you like to reinstall the current version? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Reinstallation cancelled."
            exit 0
        fi
    fi
fi

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
    
    # Checkpoint 2: Confirm desktop entry creation
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
        
        echo "Desktop entry created successfully."
    else
        echo "Skipping desktop entry creation."
    fi
    
    # Add shell alias
    read -p "Would you like to add a shell alias for Cursor? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_shell_alias
    else
        echo "Skipping shell alias setup."
    fi
else
    # For updates, ask if they want to refresh the desktop entry
    read -p "Would you like to refresh the desktop entry for Cursor? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Download icon
        echo "Downloading Cursor icon..."
        curl -L "$ICON_URL" -o /tmp/cursor.png || {
            echo "Failed to download icon. Using existing icon."
        }
        
        if [ -f "/tmp/cursor.png" ]; then
            mv /tmp/cursor.png "$ICON_PATH"
        fi
        
        # Create desktop entry
        echo "Updating desktop entry..."
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
        
        echo "Desktop entry updated successfully."
    fi
fi

# Exit section
echo
echo "=== Installation Complete ==="
show_exit_options

exit 0