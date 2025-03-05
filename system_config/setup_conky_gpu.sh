#!/bin/bash

# Create Conky configuration directory
mkdir -p ~/.config/conky

# Create Conky configuration file
cat > ~/.config/conky/conky.conf << 'EOF'
conky.config = {
    alignment = 'top_right',
    background = true,
    border_width = 1,
    cpu_avg_samples = 2,
    default_color = 'white',
    default_outline_color = 'white',
    default_shade_color = 'white',
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    extra_newline = false,
    font = 'DejaVu Sans Mono:size=9.6',
    gap_x = 20,
    gap_y = 40,
    minimum_height = 5,
    minimum_width = 280,
    net_avg_samples = 2,
    no_buffers = true,
    out_to_console = false,
    out_to_ncurses = false,
    out_to_stderr = false,
    out_to_x = true,
    own_window = true,
    own_window_class = 'Conky',
    own_window_type = 'desktop',
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager,above',
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_argb_value = 30,
    show_graph_range = false,
    show_graph_scale = false,
    stippled_borders = 0,
    update_interval = 1.0,
    uppercase = false,
    use_spacer = 'none',
    use_xft = true,
    color1 = '#8888cc',
    color2 = '#88cc88',
    color3 = '#cccc88',
}

conky.text = [[
${color1}Info:$color ${scroll 32 $sysname $nodename $kernel $machine}
$hr
${color1}Uptime:$color $uptime
${color1}Frequency (in MHz):$color $freq
${color1}Frequency (in GHz):$color ${freq_g}
${color1}RAM Usage:$color $mem/$memmax - $memperc% ${membar 4}
${color1}Swap Usage:$color $swap/$swapmax - $swapperc% ${swapbar 4}
${color1}CPU Usage:$color $cpu% ${cpubar 4}
${color1}Processes:$color $processes  ${color1}Running:$color $running_processes
$hr
${color1}File systems:
 / $color${fs_used /}/${fs_size /} ${fs_bar 6 /}
${color1}Networking:
Up:$color ${upspeed} ${color1} - Down:$color ${downspeed}
$hr
${color2}GPU Info:
${color2}GPU 0 (RTX 3090):
${color2} Temperature:$color ${execi 5 nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits -i 0}°C
${color2} Utilization:$color ${execi 5 nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader -i 0}
${color2} Memory:$color ${execi 5 nvidia-smi --query-gpu=memory.used --format=csv,noheader -i 0} / ${execi 5 nvidia-smi --query-gpu=memory.total --format=csv,noheader -i 0}
${color2} Power:$color ${execi 5 nvidia-smi --query-gpu=power.draw --format=csv,noheader -i 0}
${color2} Fan:$color ${execi 5 nvidia-smi --query-gpu=fan.speed --format=csv,noheader -i 0}

${color3}GPU 1 (GTX 980 Ti):
${color3} Temperature:$color ${execi 5 nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits -i 1}°C
${color3} Utilization:$color ${execi 5 nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader -i 1}
${color3} Memory:$color ${execi 5 nvidia-smi --query-gpu=memory.used --format=csv,noheader -i 1} / ${execi 5 nvidia-smi --query-gpu=memory.total --format=csv,noheader -i 1}
${color3} Power:$color ${execi 5 nvidia-smi --query-gpu=power.draw --format=csv,noheader -i 1}
${color3} Fan:$color ${execi 5 nvidia-smi --query-gpu=fan.speed --format=csv,noheader -i 1}
$hr
${color1}Name              PID     CPU%   MEM%
${color lightgrey} ${top name 1} ${top pid 1} ${top cpu 1} ${top mem 1}
${color lightgrey} ${top name 2} ${top pid 2} ${top cpu 2} ${top mem 2}
${color lightgrey} ${top name 3} ${top pid 3} ${top cpu 3} ${top mem 3}
${color lightgrey} ${top name 4} ${top pid 4} ${top cpu 4} ${top mem 4}
]]
EOF

# Create Conky startup script
cat > ~/.config/conky/start_conky.sh << 'EOF'
#!/bin/bash

# Kill any running Conky instances
killall conky 2>/dev/null

# Wait a moment to ensure Conky is fully stopped
sleep 2

# Start Conky with our custom configuration
conky -c ~/.config/conky/conky.conf &

exit 0
EOF

# Make the startup script executable
chmod +x ~/.config/conky/start_conky.sh

# Create autostart entry for Conky
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/conky.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Conky
Comment=Start Conky system monitor
Exec=/home/$USER/.config/conky/start_conky.sh
Terminal=false
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# Kill any running Conky instances
killall conky 2>/dev/null

# Wait a moment to ensure Conky is fully stopped
sleep 2

# Start Conky with our custom configuration
~/.config/conky/start_conky.sh

echo "Conky with GPU monitoring has been set up and started." 