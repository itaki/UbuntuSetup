#!/bin/bash

# Function to extract version number from filename
get_version() {
    local filename=$1
    echo "$filename" | grep -o '[0-9]\+\.[0-9]\+v[0-9]\+'
}

# Function to find Nuke installer
find_installer() {
    local downloads_dir="$HOME/Downloads"
    local manual_path=""
    
    # First try Downloads folder
    local installer=$(ls "$downloads_dir"/Nuke*-linux-x86_64.run 2>/dev/null | sort -V | tail -n 1)
    
    if [ -n "$installer" ]; then
        echo "$installer"
        return 0
    fi
    
    # If not found in Downloads, ask for manual path
    echo "No Nuke installer found in Downloads folder."
    echo "Would you like to:"
    echo "1. Enter the path to the installer"
    echo "2. Quit"
    read -p "Enter your choice (1 or 2): " choice
    
    case $choice in
        1)
            read -p "Please enter the full path to the Nuke installer: " manual_path
            if [ -f "$manual_path" ] && [[ "$manual_path" == *"Nuke"*"-linux-x86_64.run" ]]; then
                echo "$manual_path"
                return 0
            else
                echo "Error: Invalid installer path or file not found."
                return 1
            fi
            ;;
        2)
            echo "Installation cancelled."
            return 1
            ;;
        *)
            echo "Invalid choice. Installation cancelled."
            return 1
            ;;
    esac
}

# Check if script is running from the correct directory
if [ ! -f "nuke_icon.png" ] || [ ! -f "nukex_icon.png" ]; then
    echo "Error: Custom icons not found!"
    echo "Please run this script from the directory containing the Nuke icons."
    exit 1
fi

# Find the Nuke installer
NUKE_INSTALLER=$(find_installer)

if [ $? -ne 0 ]; then
    exit 1
fi

# Extract version number
VERSION=$(get_version "$(basename "$NUKE_INSTALLER")")
# Extract major version (15.1 from 15.1v5)
MAJOR_VERSION=$(echo "$VERSION" | sed 's/v[0-9]\+$//')

# Run the installer with EULA acceptance and specified installation directory
echo "Installing Nuke to /usr/local..."
sudo "$NUKE_INSTALLER" --accept-foundry-eula --prefix="/usr/local"

# Get the full installation directory name (e.g., Nuke15.1v5)
INSTALL_DIR="Nuke$VERSION"
NUKE_EXEC="$INSTALL_DIR/Nuke$MAJOR_VERSION"

# Create icons directory if it doesn't exist
for SIZE in 256x256 48x48; do
    ICONS_DIR="/usr/share/icons/hicolor/$SIZE/apps"
    sudo mkdir -p "$ICONS_DIR"
done

# Copy our custom icons
sudo cp "nuke_icon.png" "/usr/share/icons/hicolor/256x256/apps/nuke$VERSION.png"
sudo cp "nukex_icon.png" "/usr/share/icons/hicolor/256x256/apps/nukex$VERSION.png"

# Create folder icon directory and copy folder icon
sudo mkdir -p "/usr/share/icons/hicolor/48x48/places"
sudo cp "nuke_folder_icon.png" "/usr/share/icons/hicolor/48x48/places/folder-nuke.png"

# Create desktop entry for Nuke
cat > "/tmp/nuke$VERSION.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Nuke $VERSION
GenericName=Compositing Software
Comment=Professional compositing, editorial and review software
Exec=/usr/local/$NUKE_EXEC
Icon=nuke$VERSION
Terminal=false
Categories=Graphics;2DGraphics;RasterGraphics;
Keywords=nuke;compositing;vfx;
StartupNotify=true
StartupWMClass=Nuke$MAJOR_VERSION
EOF

# Create desktop entry for NukeX
cat > "/tmp/nukex$VERSION.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=NukeX $VERSION
GenericName=Compositing Software
Comment=Professional compositing, editorial and review software with additional features
Exec=/usr/local/$NUKE_EXEC --nukex
Icon=nukex$VERSION
Terminal=false
Categories=Graphics;2DGraphics;RasterGraphics;
Keywords=nuke;nukex;compositing;vfx;
StartupNotify=true
StartupWMClass=Nuke$MAJOR_VERSION
EOF

# Move desktop entries to applications directory
sudo mv "/tmp/nuke$VERSION.desktop" "/usr/share/applications/"
sudo mv "/tmp/nukex$VERSION.desktop" "/usr/share/applications/"

# Set proper permissions
sudo chmod +x "/usr/share/applications/nuke$VERSION.desktop"
sudo chmod +x "/usr/share/applications/nukex$VERSION.desktop"

# Create symlinks in /usr/local/bin for command line access
sudo ln -sf "/usr/local/$NUKE_EXEC" "/usr/local/bin/nuke$VERSION"
sudo ln -sf "/usr/local/$NUKE_EXEC" "/usr/local/bin/nukex$VERSION"

# Create Nuke scripts directory with custom icon
NUKE_SCRIPTS_DIR="$HOME/.nuke"
mkdir -p "$NUKE_SCRIPTS_DIR"

# Create or update user's init.py
INIT_PY="$NUKE_SCRIPTS_DIR/init.py"
if [ ! -f "$INIT_PY" ]; then
    cat > "$INIT_PY" << EOF
# Nuke initialization file
import nuke

# Add any custom Nuke initialization here
EOF
fi

# Update icon cache
sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor

echo "Installation complete! You can now:"
echo "1. Launch Nuke from your applications menu (should be pinnable to dash)"
echo "2. Run 'nuke$VERSION' from terminal for Nuke"
echo "3. Run 'nukex$VERSION' from terminal for NukeX"
echo "4. Your Nuke scripts directory is set up at: $NUKE_SCRIPTS_DIR"

echo -e "\nNote: You may need to log out and back in for the application icons to appear correctly in the menu." 