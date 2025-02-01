#!/bin/bash

installCursor() {
    local CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
    local ICON_URL="https://miro.medium.com/v2/resize:fit:700/1*YLg8VpqXaTyRHJoStnMuog.png"
    local LOCAL_APPS="$HOME/.local/share/applications"
    local LOCAL_BIN="$HOME/.local/bin"
    local LOCAL_ICONS="$HOME/.local/share/icons"
    local APPIMAGE_PATH="$LOCAL_BIN/cursor.appimage"
    local ICON_PATH="$LOCAL_ICONS/cursor.png"
    local DESKTOP_ENTRY_PATH="$LOCAL_APPS/cursor.desktop"

    # Create necessary directories if they don't exist
    mkdir -p "$LOCAL_APPS" "$LOCAL_BIN" "$LOCAL_ICONS"

    echo "Checking for existing Cursor installation..."

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
            return 1
            ;;
    esac

    # Notify if updating an existing installation
    if [ -f "$APPIMAGE_PATH" ]; then
        echo "Cursor AI IDE is already installed. Updating existing installation..."
    else
        echo "Performing a fresh installation of Cursor AI IDE..."
    fi

    # Install curl if not installed
    if ! command -v curl &> /dev/null; then
        echo "curl is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y curl || { echo "Failed to install curl."; exit 1; }
    fi

    # Download AppImage and Icon
    echo "Downloading Cursor AppImage..."
    curl -L "$CURSOR_URL" -o /tmp/cursor.appimage || { echo "Failed to download AppImage."; exit 1; }

    echo "Downloading Cursor icon..."
    curl -L "$ICON_URL" -o /tmp/cursor.png || { echo "Failed to download icon."; exit 1; }

    # Move to final destination
    echo "Installing Cursor files..."
    mv /tmp/cursor.appimage "$APPIMAGE_PATH"
    chmod +x "$APPIMAGE_PATH"
    mv /tmp/cursor.png "$ICON_PATH"

    # Create a .desktop entry
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

    # Add alias to the appropriate RC file
    echo "Adding cursor alias to $RC_FILE..."
    if [ "$SHELL_NAME" = "fish" ]; then
        # Fish shell uses a different syntax for functions
        if ! grep -q "function cursor" "$RC_FILE"; then
            echo "function cursor" >> "$RC_FILE"
            echo "    $APPIMAGE_PATH --no-sandbox \$argv > /dev/null 2>&1 & disown" >> "$RC_FILE"
            echo "end" >> "$RC_FILE"
        else
            echo "Alias already exists in $RC_FILE."
        fi
    else
        if ! grep -q "function cursor" "$RC_FILE"; then
            cat >> "$RC_FILE" <<EOL

# Cursor alias
function cursor() {
    $APPIMAGE_PATH --no-sandbox "\${@}" > /dev/null 2>&1 & disown
}
EOL
        else
            echo "Alias already exists in $RC_FILE."
        fi
    fi

    # Update desktop database
    update-desktop-database "$LOCAL_APPS"

    # Inform the user to reload the shell
    echo "To apply changes, please restart your terminal or run the following command:"
    echo "    source $RC_FILE"

    echo "Cursor AI IDE installation complete. You can find it in your application menu."
    echo "If the icon doesn't appear immediately, try logging out and back in,"
    echo "or running: gtk-update-icon-cache -f -t ~/.local/share/icons"
}

installCursor
