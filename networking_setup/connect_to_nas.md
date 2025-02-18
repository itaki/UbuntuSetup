nstalling and setting up SAMBA

Here's the essential step-by-step guide to set up SMB shares on Ubuntu for QNAP NAS access:

1. Install required packages:

```
sudo apt install samba samba-common gvfs-backends gvfs-fuse
```

2. Create and edit the Samba configuration file:
```
sudo nano /etc/samba/smb.conf
```


3. Add these specific settings to the [global] section:
```
[global]
client min protocol = SMB2
client max protocol = SMB3
security = user
name resolve order = bcast host
ntlm auth = yes
client use spnego = yes
disable netbios = yes
```


4. Restart the GVFS daemon:

```
systemctl --user restart gvfs-daemon
```

That's it! The key was getting the right SMB protocol settings in place and disabling NetBIOS. After this, you should be able to see and connect to QNAP shares in the Ubuntu file browser.

Note: When connecting, use your QNAP username and password, and leave the domain field blank.