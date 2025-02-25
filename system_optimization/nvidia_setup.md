# NVIDIA GPU Setup and Configuration

## System Configuration
- **GPUs**: 
  - NVIDIA GeForce RTX 3090 (Compute GPU)
  - NVIDIA GeForce GTX 980 Ti (Display GPU)

## Changes Made

### 1. Time Synchronization Service
- Switched from `systemd-timesyncd` to `chrony`
- Commands executed:
  ```bash
  sudo systemctl stop systemd-timesyncd
  sudo systemctl disable systemd-timesyncd
  sudo apt install chrony
  ```
- Purpose: To improve system time synchronization accuracy

### 2. GRUB Configuration
- Modified `/etc/default/grub`
- Added parameters:
  ```
  GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1 pci=assign-busses,realloc nvidia-drm.primary_device_index=1"
  ```
- Purpose:
  - `nvidia-drm.modeset=1`: Enable NVIDIA DRM kernel mode setting
  - `pci=assign-busses,realloc`: Manage PCI bus assignments
  - `nvidia-drm.primary_device_index=1`: Set GTX 980 Ti as primary display GPU

### 3. NVIDIA Driver Installation
- Removed manually installed driver:
  ```bash
  sudo apt-get remove --purge 'nvidia*'
  sudo apt-get autoremove
  ```
- Installed official package:
  ```bash
  sudo apt install nvidia-driver-550
  ```
- Current version: 550.120
- Purpose: Switch to package-managed driver for better system integration

### 4. Display Server Configuration
- Switched from Wayland to X11
- Modified `/etc/gdm3/custom.conf`:
  ```bash
  WaylandEnable=false
  ```
- Purpose: Improve compatibility between NVIDIA drivers and display server
- Expected Benefits:
  - Better cursor handling
  - Improved input responsiveness
  - More stable display performance with NVIDIA GPUs

### 5. GRUB Menu Visibility Fix
- Modified `/etc/default/grub`:
  ```bash
  GRUB_TIMEOUT_STYLE=menu
  GRUB_TIMEOUT=5
  ```
- Purpose: Make GRUB menu visible during boot
- Commands executed:
  ```bash
  sudo sed -i 's/GRUB_TIMEOUT_STYLE=hidden/GRUB_TIMEOUT_STYLE=menu/' /etc/default/grub
  sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/' /etc/default/grub
  sudo update-grub
  ```
- Benefits:
  - Access to boot options during startup
  - Ability to select recovery mode if needed
  - Better visibility of boot process

## Boot Issues Encountered

### Boot Failure with Blinking Cursor
- **Issue**: After applying GRUB changes, system failed to boot properly
- **Symptoms**: 
  - No GRUB menu
  - Ubuntu logo appeared
  - Boot messages displayed
  - System hung at blinking cursor
- **Recovery Steps**:
  1. Booted from live CD
  2. Reverted Wayland changes
  3. Removed NVIDIA-specific parameters from GRUB
  4. Updated GRUB configuration
  5. Successfully booted system

### GRUB Menu Visibility Issue
- **Issue**: GRUB menu not appearing during boot
- **Symptoms**:
  - Black screen until login window appears
  - No opportunity to select different kernel or recovery options
- **Potential Causes**:
  - GRUB timeout set too low
  - GRUB configured to hide menu unless Shift key is pressed
  - Display output routing issues with multiple GPUs
- **Resolution**:
  - Changed GRUB timeout style from hidden to menu
  - Increased timeout from 0 to 5 seconds

### Lessons Learned
1. Make one configuration change at a time
2. Create backups before modifying system files
3. Test GRUB parameters temporarily before committing them
4. Ensure recovery options are available
5. Verify GPU indexing before setting primary device

## Current Status
- Both GPUs are functioning correctly:
  - RTX 3090: Available for compute workloads
  - GTX 980 Ti: Handling display output
- GRUB menu visible during boot
- System using X11 display server
- NVIDIA driver 550.120 properly installed

## Next Steps

### Optimize Current Configuration
- Fine-tune GPU settings for specific workloads
- Monitor system stability and performance
- Address any remaining input/cursor issues

## Potential Issues
The cursor behavior issue (flashing forward/backward while typing) might be related to:
1. The `nvidia-drm.modeset=1` parameter in GRUB
2. The GPU primary device index setting (`nvidia-drm.primary_device_index=1`)
3. ~~Wayland compatibility issues~~ (Resolved by switching to X11)

These settings affect how the system handles display output and could potentially interfere with input handling. 