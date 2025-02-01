#!/bin/bash

# Function to setup VNC
setup_vnc() {
    # Install required packages
    sudo apt update
    sudo apt install -y tigervnc-standalone-server tigervnc-common net-tools

    # Create VNC password
    mkdir -p ~/.vnc
    echo "Setting up VNC password..."
    vncpasswd

    # Create xstartup file
    cat > ~/.vnc/xstartup <<EOL
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="GNOME"
exec dbus-launch --exit-with-session gnome-session
EOL

    # Make xstartup executable
    chmod +x ~/.vnc/xstartup

    # Create systemd user service for VNC
    mkdir -p ~/.config/systemd/user
    cat > ~/.config/systemd/user/vncserver@.service <<EOL
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=simple
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill :%i > /dev/null 2>&1 || :'
ExecStart=/usr/bin/vncserver :%i -geometry 1920x1080 -depth 16 -quality 7 -encodings "copyrect tight hextile" -localhost no
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=default.target
EOL

    # Allow VNC through firewall
    sudo ufw allow 5901/tcp

    # Enable and start VNC service
    systemctl --user daemon-reload
    systemctl --user enable vncserver@1.service
    systemctl --user start vncserver@1.service

    # Get IP address
    IP=$(hostname -I | awk '{print $1}')
    
    echo "VNC Server setup complete!"
    echo "To connect from another computer:"
    echo "1. Use a VNC viewer (like TigerVNC or Apple Screen Sharing)"
    echo "2. Connect to: ${IP}:5901"
    echo ""
    echo "To check service status:"
    echo "systemctl --user status vncserver@1.service"
    echo ""
    echo "For better performance, you can adjust these settings:"
    echo "- Quality (1-9): Currently set to 7"
    echo "- Color depth: Currently set to 16-bit"
    echo "Edit ~/.config/systemd/user/vncserver@.service to change these settings"
}

# Run the setup
setup_vnc 