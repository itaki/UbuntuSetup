# Setting up VNC Server on Ubuntu

This guide explains how to set up a VNC server using TigerVNC on Ubuntu. TigerVNC provides better performance and compatibility compared to other VNC servers.

## Installation

1. Install TigerVNC server and GNOME Flashback session:
```bash
sudo apt install -y gnome-session-flashback tigervnc-standalone-server
```

## Configuration

1. Create the VNC startup script:
```bash
mkdir -p ~/.vnc
nano ~/.vnc/xstartup
```

2. Add the following content to `~/.vnc/xstartup`:
```bash
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources

export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="GNOME-Flashback:Unity"
export XDG_MENU_PREFIX="gnome-flashback-"

gnome-session --session=gnome-flashback-metacity --disable-acceleration-check
```

3. Make the startup script executable:
```bash
chmod +x ~/.vnc/xstartup
```

4. Set up a VNC password:
```bash
vncpasswd
```
Enter and confirm your desired password when prompted. You can skip setting a view-only password.

## Starting the VNC Server

1. Start the VNC server:
```bash
vncserver :2 -geometry 1920x1080 -depth 16 -localhost no
```
This will start the server on port 5902 (display :2).

## Connecting to the VNC Server

You can connect to the VNC server in several ways:

1. Using TigerVNC Viewer:
```bash
vncviewer <server-ip>:5902
```

2. Using Apple's Screen Sharing (on macOS):
- Press Cmd+K in Finder
- Enter: `vnc://<server-ip>:5902`

3. Using SSH tunneling (recommended for security):
```bash
vncviewer -via username@<server-ip> localhost::5902
```

## Stopping the VNC Server

To stop the VNC server:
```bash
vncserver -kill :2
```

## Troubleshooting

1. If you get a "server already running" error:
```bash
vncserver -kill :1  # Kill display :1
vncserver -kill :2  # Kill display :2
rm -rf /tmp/.X*-lock /tmp/.X11-unix/X*  # Clean up lock files
```

2. Check VNC server status:
```bash
ps aux | grep vnc
```

## Security Notes

- The VNC protocol itself is not encrypted. For secure remote access, use SSH tunneling.
- Always use strong passwords for VNC authentication.
- Consider using `-localhost yes` and SSH tunneling for additional security.

## Performance Tips

- The GNOME Flashback session provides better performance than standard GNOME.
- Adjust the geometry and color depth as needed for your connection speed.
- Use compression options in your VNC viewer for slower connections.