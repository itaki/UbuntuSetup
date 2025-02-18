# RLM License Server Installation Documentation

## Purpose
This set of scripts automates the installation and management of the Reprise License Manager (RLM) server for multiple software packages including Foundry's Nuke, GenArts, PeregrineLabs, and Maxwell.

## Available Scripts

- `rlm_install.sh` - Main installation script
- `rlm_client.sh` - Client configuration script
- `rlm_uninstall.sh` - Uninstallation script
- `rlmd` - RLM daemon configuration

## Prerequisites

- Sudo privileges
- Systemd-based Linux distribution (Ubuntu)
- Valid license files for your software

## Features

- Installs RLM server to `/opt/rlm`
- Sets up license directories for multiple software packages:
  - Foundry (Nuke): `/usr/local/foundry/RLM`
  - GenArts: `/usr/genarts/rlm`
  - PeregrineLabs: `/var/PeregrineLabs/rlm`
  - Maxwell: `$HOME/Maxwell`
- Configures systemd service with proper logging
- Sets up environment variables in bash startup files
- Creates necessary directory structure and permissions
- Provides client-side configuration options

## Installation Process

1. Extracts RLM package to `/opt/rlm`
2. Sets up license directories for each supported software
3. Configures environment variables
4. Creates and enables systemd service
5. Sets proper permissions for all components

## Usage

For server installation:
```bash
./rlm_install.sh
```

For client setup:
```bash
./rlm_client.sh
```

To uninstall:
```bash
./rlm_uninstall.sh
```

## Post-Installation

After installation, you can:

1. Check service status: `sudo systemctl status rlmd`
2. Check license status: `sudo /opt/rlm/rlmutil rlmstat -a`
3. View logs: `cat /opt/rlm/rlm_lic.dlog`
4. Manage service:
   - Stop: `sudo systemctl stop rlmd`
   - Start: `sudo systemctl start rlmd`
   - Restart: `sudo systemctl restart rlmd`

## License Configuration

The script automatically sets up license files in their respective directories:

1. Foundry licenses in `/usr/local/foundry/RLM`
2. GenArts licenses in `/usr/genarts/rlm`
3. PeregrineLabs licenses in `/var/PeregrineLabs/rlm`
4. Maxwell licenses in `$HOME/Maxwell`

Note: You need to replace the default license files with your valid license files after installation. 