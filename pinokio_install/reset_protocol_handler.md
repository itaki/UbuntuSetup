# Resetting Pinokio Protocol Handler

This document explains how to reset the Pinokio protocol handler when it's not working correctly.

## Problem

When installing Pinokio applications from GitHub or other sources, you click on an installation link that uses the `pinokio://` protocol. This should open Pinokio and trigger the installation process. However, if you accidentally set a different application as the default handler for the `pinokio://` protocol, these links will no longer work correctly.

Common symptoms of this issue:
- Clicking on Pinokio installation links does nothing
- Clicking on Pinokio installation links opens the wrong application
- You previously selected "Always use this application" for a different application when prompted

## Solution

The `reset_protocol_handler.sh` script fixes this issue by:

1. Removing any existing associations for the `pinokio://` protocol from various configuration files
2. Deleting any existing Pinokio protocol handler desktop files
3. Creating a fresh desktop entry for the Pinokio protocol handler
4. Re-registering Pinokio as the default handler for the `pinokio://` protocol
5. Creating a test link on the desktop to verify the fix

## How It Works

The script performs the following operations:

1. Cleans up protocol handler associations in:
   - `~/.config/mimeapps.list`
   - `~/.local/share/applications/mimeapps.list`
   - `~/.local/share/applications/defaults.list`
   - `~/.local/share/applications/mimeinfo.cache`

2. Removes any existing Pinokio protocol handler desktop files

3. Creates a new desktop entry file at `~/.local/share/applications/pinokio-protocol.desktop`

4. Registers this desktop entry as the default handler for the `pinokio://` protocol using `xdg-mime`

5. Updates the desktop database to apply the changes

6. Creates a test link on the desktop that you can click to verify the fix

## Usage

To use this script:

1. Make it executable:
   ```bash
   chmod +x reset_protocol_handler.sh
   ```

2. Run it:
   ```bash
   ./reset_protocol_handler.sh
   ```

3. Click on the test link created on your desktop to verify that the protocol handler is working correctly

## Troubleshooting

If the protocol handler still doesn't work after running the script:

1. Log out and log back in to refresh the system
2. Verify that Pinokio is properly installed at `/opt/Pinokio/pinokio`
3. Try running the following command in a terminal to test the protocol handler:
   ```bash
   xdg-open "pinokio://download?uri=https://github.com/facefusion/facefusion-pinokio"
   ```
4. Check if there are any error messages in the terminal when running the above command

## What Didn't Work

During our troubleshooting, we found that:

1. Simply re-registering the protocol handler without cleaning up existing associations didn't work
2. The system may cache protocol handler preferences, requiring a logout/login to fully apply changes
3. Multiple configuration files can contain protocol handler associations, and all need to be cleaned
