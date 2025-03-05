# Conky GPU Monitoring Setup

This document explains how to set up Conky to monitor NVIDIA GPUs on Ubuntu.

## Overview

Conky is a lightweight system monitor that can display various system information on your desktop. This setup configures Conky to show detailed information about your NVIDIA GPUs, including:

- GPU temperature
- GPU utilization
- Memory usage
- Power consumption
- Fan speed

The setup is configured for a system with two NVIDIA GPUs (RTX 3090 and GTX 980 Ti), but can be easily modified for different GPU configurations.

## Installation

The `setup_conky_gpu.sh` script automates the installation and configuration of Conky with GPU monitoring. It performs the following tasks:

1. Creates a Conky configuration directory in `~/.config/conky/`
2. Creates a custom Conky configuration file with GPU monitoring
3. Creates a startup script to properly launch Conky
4. Sets up Conky to start automatically at login
5. Starts Conky with the new configuration

To install, simply run:

```bash
./setup_conky_gpu.sh
```

## Configuration Details

The Conky configuration includes:

- System information (hostname, kernel, uptime)
- CPU usage and frequency
- Memory and swap usage
- File system usage
- Network traffic
- Detailed GPU information for both GPUs
- Top processes by CPU and memory usage

### Visual Settings

The current configuration has the following visual settings:

- Position: Top right corner of the screen
- Size: Compact (20% smaller than default)
- Transparency: Very dim (30% opacity)
- Always on top: Yes
- Colors: Soft blue for system info, soft green for GPU 0, soft yellow for GPU 1

## How It Works

The configuration uses `nvidia-smi` commands to query GPU information. For example:

```
${execi 5 nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits -i 0}°C
```

This command:
- Runs every 5 seconds (`execi 5`)
- Uses `nvidia-smi` to query the temperature of GPU 0
- Formats the output as CSV without headers or units
- Appends °C to the result

## Troubleshooting

If Conky is not displaying GPU information:

1. Verify that `nvidia-smi` is installed and working:
   ```bash
   nvidia-smi
   ```

2. Check if the Conky process is running:
   ```bash
   pgrep -a conky
   ```

3. Restart Conky:
   ```bash
   ~/.config/conky/start_conky.sh
   ```

4. Check the Conky configuration file for errors:
   ```bash
   conky -c ~/.config/conky/conky.conf
   ```

## Customization

To modify the configuration:

1. Edit the Conky configuration file:
   ```bash
   nano ~/.config/conky/conky.conf
   ```

2. Common customization options:
   - Change `alignment` to position Conky (top_right, top_left, bottom_right, bottom_left, etc.)
   - Adjust `own_window_argb_value` for transparency (0-255, where 0 is fully transparent)
   - Modify `font` size for larger or smaller text
   - Change `gap_x` and `gap_y` to adjust the distance from screen edges
   - Edit `color1`, `color2`, and `color3` values to change the color scheme

3. Restart Conky to apply changes:
   ```bash
   ~/.config/conky/start_conky.sh
   ```

## Alternative GPU Monitoring Tools

If Conky doesn't meet your needs, consider these alternatives:

1. **nvidia-smi**: Command-line tool for monitoring NVIDIA GPUs
   ```bash
   watch -n 1 nvidia-smi
   ```

2. **nvtop**: Terminal-based NVIDIA GPU activity monitor
   ```bash
   sudo apt install nvtop
   ```

3. **GreenWithEnvy**: GUI application for monitoring and controlling NVIDIA GPUs
   ```bash
   sudo apt install gwe
   ```

4. **psensor**: Graphical hardware temperature monitor
   ```bash
   sudo apt install psensor
   ``` 