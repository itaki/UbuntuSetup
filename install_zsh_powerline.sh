#!/bin/bash

echo "Installing Oh My Zsh, Meslo Nerd Fonts, and Powerlevel10k..."

# Install required packages
echo "Installing required packages..."
sudo apt update
sudo apt install -y zsh curl git

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed"
else
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Meslo Nerd Font
echo "Installing Meslo Nerd Font..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
echo "Downloading font files..."
curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fc-cache -f -v

# Install Powerlevel10k
echo "Installing Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Configure .zshrc
echo "Configuring .zshrc..."
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

# Set Zsh as default shell
echo "Setting Zsh as default shell..."
chsh -s $(which zsh)

# Cursor configuration
echo -e "\nWould you like to configure Cursor settings for the new font and shell? (y/n)"
read -r configure_cursor

if [ "$configure_cursor" = "y" ] || [ "$configure_cursor" = "Y" ]; then
    CURSOR_SETTINGS="$HOME/.config/Cursor/User/settings.json"
    
    if [ -f "$CURSOR_SETTINGS" ]; then
        echo "Backing up current settings..."
        cp "$CURSOR_SETTINGS" "$CURSOR_SETTINGS.backup"
        
        # Create new settings with required configurations
        cat > "$CURSOR_SETTINGS" << EOL
{
    "diffEditor.renderSideBySide": true,
    "chatgpt.lang": "en",
    "explorer.confirmDragAndDrop": false,
    "terminal.integrated.fontFamily": "MesloLGS NF",
    "editor.fontFamily": "'MesloLGS NF', 'Noto Color Emoji', 'monospace'",
    "explorer.confirmDelete": false,
    "files.autoSave": "afterDelay",
    "git.autofetch": true,
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "terminal.integrated.defaultProfile.linux": "zsh",
    "[python]": {
        "diffEditor.ignoreTrimWhitespace": false,
        "editor.defaultColorDecorators": "never",
        "gitlens.codeLens.symbolScopes": [
            "!Module"
        ],
        "editor.formatOnType": true,
        "editor.wordBasedSuggestions": "off"
    },
    "terminal.integrated.profiles.linux": {
        "zsh": {
            "path": "zsh"
        },
        "bash": {
            "path": "bash",
            "icon": "terminal-bash"
        },        
        "fish": {
            "path": "fish"
        },
        "tmux": {
            "path": "tmux",
            "icon": "terminal-tmux"
        },
        "pwsh": {
            "path": "pwsh",
            "icon": "terminal-powershell"
        }
    }
}
EOL
        echo "Cursor settings have been updated. A backup of your previous settings was saved as settings.json.backup"
    else
        echo "Error: Cursor settings file not found at $CURSOR_SETTINGS"
        echo "Please make sure Cursor is installed and has been run at least once"
    fi
else
    echo -e "\nTo manually configure Cursor settings:"
    echo "1. Open Cursor"
    echo "2. Go to Settings (Ctrl+,)"
    echo "3. Add these settings to your settings.json:"
    echo "   \"terminal.integrated.fontFamily\": \"MesloLGS NF\""
    echo "   \"editor.fontFamily\": \"'MesloLGS NF', 'Noto Color Emoji', 'monospace'\""
    echo "   \"terminal.integrated.defaultProfile.linux\": \"zsh\""
    echo -e "\nSettings file location: $HOME/.config/Cursor/User/settings.json"
fi

echo -e "\nInstallation complete!"
echo "Please:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Restart Cursor to apply the new settings"
echo "3. When you first start a new terminal, you'll see the Powerlevel10k configuration wizard"
echo "   If it doesn't start automatically, run: p10k configure" 