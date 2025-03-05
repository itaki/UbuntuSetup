# NoMachine Installation

This document explains how to install NoMachine on Ubuntu.

## What is NoMachine?

NoMachine is a remote desktop software that allows you to access your computer from anywhere. It provides a fast and secure way to connect to your desktop environment remotely, with features like file sharing, audio/video support, and multi-platform compatibility.

## Installation Method

The simplest and most reliable way to install NoMachine on Ubuntu is through the App Center:

1. Open the Ubuntu App Center (Software Center)
2. Search for "NoMachine"
3. Click "Install"
4. Enter your password if prompted
5. Wait for the installation to complete

This method ensures that:
- You get the correct package for your system
- Dependencies are automatically handled
- The installation is properly integrated with your system
- Updates can be managed through the App Center

## Post-Installation

After installation:

- The NoMachine server will be running automatically
- You can access the NoMachine client from your applications menu
- The server configuration can be managed using: `sudo /usr/NX/bin/nxserver --status`
- To connect to this machine remotely, you'll need to know its IP address and have proper network/firewall configuration

## Troubleshooting

If you encounter issues:

1. Verify your network configuration allows NoMachine connections (default port is 4000)
2. Check the NoMachine server status: `sudo /usr/NX/bin/nxserver --status`
3. Review the NoMachine logs: `/usr/NX/var/log/`
4. Visit the NoMachine support website: https://www.nomachine.com/support

## Alternative Installation Methods

While the App Center is the recommended method, NoMachine can also be installed:

1. By downloading the .deb package from the [NoMachine website](https://www.nomachine.com/download/linux) and installing it manually
2. Using the terminal with `sudo apt install nomachine` if it's available in your repositories 