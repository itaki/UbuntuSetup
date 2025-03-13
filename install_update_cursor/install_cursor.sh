#!/bin/bash

checkDependencies() {
    local missing_deps=()
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    # Check specifically for libfuse2
    if ! ldconfig -p | grep -q libfuse.so.2; then
        missing_deps+=("libfuse2")
    fi
    
    # If there are missing dependencies, install them
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

# Function to get the latest version from the Cursor website
getLatestVersion() {
    # Try to get the version from the Cursor website
    local version=$(curl -s https://cursor.so/ | grep -oE 'Version [0-9]+\.[0-9]+(\.[0-9]+)?' | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    
    # If that fails, try the downloads page
    if [ -z "$version" ]; then
        version=$(curl -s https://www.cursor.com/downloads | grep -oE 'Version \([0-9]+\.[0-9]+\)' | grep -oE '[0-9]+\.[0-9]+' | head -1)
    fi
    
    # If we still don't have a version, use a default
    if [ -z "$version" ]; then
        version="46.11"
    fi
    
    echo "$version"
}

# Function to get the current installed version
getCurrentVersion() {
    local appimage_path="$1"
    
    # Check if the file exists
    if [ ! -f "$appimage_path" ]; then
        echo "Not installed"
        return
    fi
    
    # Try to get the version by running the AppImage
    local version=$("$appimage_path" --no-sandbox --version 2>/dev/null | grep -oE '(4[0-9]+|5[0-9]+)\.[0-9]+(\.[0-9]+)?' | head -1)
    
    # If that fails, try extracting from the AppImage itself
    if [ -z "$version" ]; then
        version=$(strings "$appimage_path" | grep -oE 'Cursor/[0-9]+\.[0-9]+\.[0-9]+' | head -1 | cut -d'/' -f2)
    fi
    
    # If we still don't have a version, try one more approach
    if [ -z "$version" ]; then
        version=$(strings "$appimage_path" | grep -A5 '"version":' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    fi
    
    # Validate that the version looks like a Cursor version (currently in the 40s or 50s)
    if [ -n "$version" ]; then
        local major=$(echo "$version" | cut -d. -f1)
        if [ "$major" -lt 40 ] || [ "$major" -gt 60 ]; then
            # This doesn't look like a valid Cursor version
            version="Unknown"
        fi
    else
        version="Unknown"
    fi
    
    echo "$version"
}

# Function to check if Cursor is running and optionally kill it
checkAndKillCursor() {
    local force_kill=$1
    local script_pid=$$
    
    # Check if any Cursor processes are running (excluding this script)
    if pgrep -f "cursor" | grep -v "$script_pid" | grep -v "install_cursor.sh" > /dev/null; then
        if [ "$force_kill" = "true" ]; then
            echo "Killing all Cursor processes (except this installer)..."
            # Kill all cursor processes except this script
            for pid in $(pgrep -f "cursor" | grep -v "$script_pid" | grep -v "install_cursor.sh"); do
                echo "Killing process $pid"
                kill $pid 2>/dev/null
            done
            sleep 2
            
            # If processes are still running, use SIGKILL
            if pgrep -f "cursor" | grep -v "$script_pid" | grep -v "install_cursor.sh" > /dev/null; then
                echo "Some Cursor processes are still running. Using force kill..."
                for pid in $(pgrep -f "cursor" | grep -v "$script_pid" | grep -v "install_cursor.sh"); do
                    echo "Force killing process $pid"
                    kill -9 $pid 2>/dev/null
                done
                sleep 1
            fi
            
            # Final check
            if pgrep -f "cursor" | grep -v "$script_pid" | grep -v "install_cursor.sh" > /dev/null; then
                echo "ERROR: Unable to kill all Cursor processes. Please close Cursor manually."
                return 1
            else
                echo "All Cursor processes successfully terminated."
                return 0
            fi
        else
            echo "Cursor is currently running."
            echo "Please close all Cursor windows and processes before updating."
            echo "Alternatively, you can force-kill all Cursor processes."
            read -p "Do you want to force-kill all Cursor processes? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                checkAndKillCursor "true"
                return $?
            else
                echo "Update canceled. Please close Cursor manually and try again."
                return 1
            fi
        fi
    fi
    
    return 0
}

installCursor() {
    local CURSOR_URL="https://cursor.so/resources/linux/cursor.appimage"
    local ICON_URL="https://miro.medium.com/v2/resize:fit:700/1*YLg8VpqXaTyRHJoStnMuog.png"
    local LOCAL_APPS="$HOME/.local/share/applications"
    local LOCAL_BIN="$HOME/.local/bin"
    local LOCAL_ICONS="$HOME/.local/share/icons"
    local APPIMAGE_PATH="$LOCAL_BIN/cursor.appimage"
    local ICON_PATH="$LOCAL_ICONS/cursor.png"
    local DESKTOP_ENTRY_PATH="$LOCAL_APPS/cursor.desktop"

    echo "Checking for dependencies..."
    checkDependencies

    # Create necessary directories if they don't exist
    mkdir -p "$LOCAL_APPS" "$LOCAL_BIN" "$LOCAL_ICONS"

    # Check for Cursor process and offer to kill it if running
    if ! checkAndKillCursor "false"; then
        exit 1
    fi

    # Get the latest version
    local LATEST_VERSION=$(getLatestVersion)
    
    # Check if Cursor is already installed
    if [ -f "$APPIMAGE_PATH" ]; then
        local CURRENT_VERSION=$(getCurrentVersion "$APPIMAGE_PATH")
        
        if [ "$CURRENT_VERSION" = "Unknown" ]; then
            echo "Current Cursor version: Unknown"
        else
            echo "Current Cursor version: $CURRENT_VERSION"
        fi
        
        echo "Latest Cursor version: $LATEST_VERSION"
        
        # Ask for confirmation before updating
        read -p "Do you want to update Cursor to version $LATEST_VERSION? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Update canceled."
            exit 0
        fi
        
        echo "Creating backup of current Cursor installation..."
        cp "$APPIMAGE_PATH" "${APPIMAGE_PATH}.backup"
    else
        echo "Cursor is not currently installed."
        echo "Latest Cursor version: $LATEST_VERSION"
        
        # Ask for confirmation before installing
        read -p "Do you want to install Cursor version $LATEST_VERSION? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation canceled."
            exit 0
        fi
    fi

    # Detect the user's shell
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
            echo "Please manually add the alias to your shell configuration file."
            ;;
    esac

    # Download AppImage and Icon
    echo "Downloading Cursor AppImage..."
    curl -L "$CURSOR_URL" -o /tmp/cursor.appimage || { 
        echo "Failed to download AppImage."
        if [ -f "${APPIMAGE_PATH}.backup" ]; then
            echo "Restoring backup..."
            mv "${APPIMAGE_PATH}.backup" "$APPIMAGE_PATH"
        fi
        exit 1
    }

    # Download icon if it doesn't exist
    if [ ! -f "$ICON_PATH" ]; then
        echo "Downloading Cursor icon..."
        curl -L "$ICON_URL" -o /tmp/cursor.png || { echo "Failed to download icon."; }
        
        if [ -f "/tmp/cursor.png" ]; then
            mv /tmp/cursor.png "$ICON_PATH"
        fi
    fi

    # Move to final destination
    echo "Installing Cursor files..."
    mv /tmp/cursor.appimage "$APPIMAGE_PATH"
    chmod +x "$APPIMAGE_PATH"

    # Create a .desktop entry if it doesn't exist
    if [ ! -f "$DESKTOP_ENTRY_PATH" ]; then
        echo "Creating .desktop entry..."
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
    fi

    # Add alias to the appropriate RC file if it doesn't exist
    if [ -n "$RC_FILE" ]; then
        if [ "$SHELL_NAME" = "fish" ]; then
            # Fish shell uses a different syntax for functions
            if ! grep -q "function cursor" "$RC_FILE"; then
                echo "Adding cursor alias to $RC_FILE..."
                echo "function cursor" >> "$RC_FILE"
                echo "    $APPIMAGE_PATH --no-sandbox \$argv > /dev/null 2>&1 & disown" >> "$RC_FILE"
                echo "end" >> "$RC_FILE"
            fi
        else
            if ! grep -q "function cursor" "$RC_FILE"; then
                echo "Adding cursor alias to $RC_FILE..."
                cat >> "$RC_FILE" <<EOL

# Cursor alias
function cursor() {
    $APPIMAGE_PATH --no-sandbox "\${@}" > /dev/null 2>&1 & disown
}
EOL
            fi
        fi
    fi

    # Update desktop database
    update-desktop-database "$LOCAL_APPS" 2>/dev/null || true

    # Test the AppImage
    echo "Testing Cursor AppImage..."
    if ! "$APPIMAGE_PATH" --no-sandbox --version &> /dev/null; then
        echo "Warning: Cursor AppImage test failed. Please check your FUSE setup."
        echo "You may need to log out and log back in for group changes to take effect."
        
        if [ -f "${APPIMAGE_PATH}.backup" ]; then
            echo "Restoring backup..."
            mv "${APPIMAGE_PATH}.backup" "$APPIMAGE_PATH"
            echo "Backup restored."
        fi
    else
        echo "Cursor $(getCurrentVersion "$APPIMAGE_PATH") installed successfully!"
        
        # Remove backup if test was successful
        if [ -f "${APPIMAGE_PATH}.backup" ]; then
            rm "${APPIMAGE_PATH}.backup"
        fi
    fi

    # Inform the user to reload the shell if needed
    if [ -n "$RC_FILE" ] && ! type cursor &>/dev/null; then
        echo "To use the 'cursor' command, please restart your terminal or run:"
        echo "    source $RC_FILE"
    fi

    echo "Cursor AI IDE installation complete. You can find it in your application menu."
    echo "If the icon doesn't appear immediately, try logging out and back in,"
    echo "or running: gtk-update-icon-cache -f -t ~/.local/share/icons"
}

installCursor