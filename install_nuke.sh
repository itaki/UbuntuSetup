#!/bin/bash

# Function to extract version number from filename
get_version() {
    local filename=$1
    echo "$filename" | grep -o '[0-9]\+\.[0-9]\+v[0-9]\+'
}

# Find the most recent Nuke installer in the nuke directory
NUKE_DIR="$HOME/UbuntuSetup/nuke"
NUKE_INSTALLER=$(ls "$NUKE_DIR"/Nuke*-linux-x86_64.run | sort -V | tail -n 1)

if [ ! -f "$NUKE_INSTALLER" ]; then
    echo "Error: No Nuke installer found in $NUKE_DIR"
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

# Copy icons from the installed Nuke
sudo cp "/usr/local/$INSTALL_DIR/plugins/icons/NukeApp256.png" "/usr/share/icons/hicolor/256x256/apps/nuke$VERSION.png"
sudo cp "/usr/local/$INSTALL_DIR/plugins/icons/NukeXApp48.png" "/usr/share/icons/hicolor/48x48/apps/nukex$VERSION.png"

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

# Update icon cache
sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor

echo "Installation complete! You can now:"
echo "1. Launch Nuke from your applications menu (should be pinnable to dash)"
echo "2. Run 'nuke$VERSION' from terminal for Nuke"
echo "3. Run 'nukex$VERSION' from terminal for NukeX"

echo -e "\nNote: You may need to log out and back in for the application icons to appear correctly in the menu." 