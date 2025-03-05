#!/bin/bash

# mac_file_sharing.sh
# Script to set up Samba file sharing for Mac access

# Exit on error
set -e

echo "Setting up Samba file sharing for Mac access..."

# Install Samba and Avahi for better Mac integration
echo "Installing Samba and Avahi..."
sudo apt update
sudo apt install -y samba samba-common-bin avahi-daemon

# Backup the original config file
echo "Backing up original Samba configuration..."
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Create a new Samba configuration
echo "Creating new Samba configuration..."
sudo tee /etc/samba/smb.conf > /dev/null << 'EOF'
[global]
   workgroup = WORKGROUP
   server string = Ubuntu File Server
   security = user
   map to guest = bad user
   dns proxy = no
   
   # Guest access
   guest account = nobody
   
   # Logging
   log file = /var/log/samba/log.%m
   max log size = 1000
   logging = file
   
   # Authentication
   passdb backend = tdbsam
   obey pam restrictions = yes
   unix password sync = yes
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
   pam password change = yes
   
   # Mac-specific settings
   min protocol = SMB2
   vfs objects = fruit streams_xattr
   fruit:metadata = stream
   fruit:model = MacSamba
   fruit:posix_rename = yes
   fruit:veto_appledouble = no
   fruit:nfs_aces = no
   fruit:wipe_intentionally_left_blank_rfork = yes
   fruit:delete_empty_adfiles = yes
   
   # Network settings
   socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
   
   # Performance
   use sendfile = yes
   aio read size = 16384
   aio write size = 16384
   
   # NetBIOS and discovery
   netbios name = UBUNTU
   multicast dns register = yes

[Home]
   comment = Home Directory
   path = /home/mm
   browseable = yes
   read only = no
   create mask = 0775
   directory mask = 0775
   valid users = mm
   force user = mm
   force group = mm

[Public]
   comment = Public Shared Folder
   path = /home/shared
   browseable = yes
   read only = no
   create mask = 0775
   directory mask = 0775
   guest ok = yes

[Sled]
   comment = Sled Drive
   path = /media/mm/sled
   browseable = yes
   read only = no
   create mask = 0775
   directory mask = 0775
   valid users = mm
   force user = mm
   force group = mm
EOF

# Create the public shared directory
echo "Creating public shared directory..."
sudo mkdir -p /home/shared
sudo chmod 777 /home/shared

# Add current user to Samba
echo "Adding current user to Samba..."
sudo smbpasswd -a $USER

# Configure Avahi for better Mac discovery
echo "Configuring Avahi for better Mac discovery..."
sudo tee /etc/avahi/services/smb.service > /dev/null << 'EOF'
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">%h</name>
  <service>
    <type>_smb._tcp</type>
    <port>445</port>
  </service>
  <service>
    <type>_device-info._tcp</type>
    <port>0</port>
    <txt-record>model=Ubuntu</txt-record>
  </service>
</service-group>
EOF

# Restart services
echo "Restarting services..."
sudo systemctl restart smbd
sudo systemctl restart nmbd
sudo systemctl restart avahi-daemon

# Configure firewall to allow Samba and Avahi
echo "Configuring firewall..."
sudo ufw allow samba
sudo ufw allow mdns

echo "Samba file sharing setup complete!"
echo "Your Ubuntu machine should now be visible in Finder on your Mac."
echo "Connect to it using: smb://$(hostname -I | awk '{print $1}')"
echo "Or by its hostname: smb://$(hostname).local"
echo ""
echo "If you don't see it in Finder, try going to Finder > Go > Connect to Server..."
echo "Then enter: smb://$(hostname -I | awk '{print $1}')" 