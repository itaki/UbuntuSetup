#!/bin/bash

echo "Applying system optimizations for AI/Video workstation..."

# Fix NVIDIA driver mismatch
echo "Updating NVIDIA drivers..."
sudo apt update
sudo apt install -y nvidia-driver-550 nvidia-utils-550

# System memory optimizations
echo "Configuring memory settings..."
sudo bash -c 'cat > /etc/sysctl.d/99-memory-optimizations.conf << EOL
# Reduce swappiness for better memory performance
vm.swappiness=10

# Optimize dirty ratio for better I/O performance
vm.dirty_ratio=30
vm.dirty_background_ratio=5

# Virtual memory optimizations
vm.vfs_cache_pressure=50
vm.page_cluster=0

# File system optimizations
fs.file-max=2097152
fs.inotify.max_user_watches=524288

# Network optimizations for data transfer
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
EOL'

# CPU Performance optimizations
echo "Configuring CPU settings..."
sudo bash -c 'cat > /etc/systemd/system/cpu-performance.service << EOL
[Unit]
Description=CPU Performance Optimization
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
ExecStart=/bin/bash -c "echo 0 > /proc/sys/kernel/numa_balancing"
ExecStart=/bin/bash -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOL'

# GPU Optimizations
echo "Configuring GPU settings..."
sudo bash -c 'cat > /etc/systemd/system/gpu-performance.service << EOL
[Unit]
Description=GPU Performance Optimization
After=multi-user.target

[Service]
Type=oneshot
# Set persistence mode
ExecStart=/usr/bin/nvidia-smi -pm 1
# Set power limit for RTX 3090
ExecStart=/usr/bin/nvidia-smi -i 0 -pl 370
# Set compute mode
ExecStart=/usr/bin/nvidia-smi -i 0 --compute-mode=0
# Set application clocks for maximum performance
ExecStart=/usr/bin/nvidia-smi -i 0 --applications-clocks=1410,1695
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOL'

# I/O Scheduler optimization for SSDs
echo "Configuring I/O scheduler..."
sudo bash -c 'cat > /etc/udev/rules.d/60-scheduler.rules << EOL
# Set scheduler to mq-deadline for NVMe SSDs
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="mq-deadline"
# Set scheduler to bfq for SATA SSDs
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="bfq"
EOL'

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable cpu-performance.service
sudo systemctl enable gpu-performance.service

# Apply sysctl settings
sudo sysctl -p /etc/sysctl.d/99-memory-optimizations.conf

# Set up IRQ affinity for GPU
echo "Setting up IRQ affinity..."
sudo bash -c 'cat > /etc/systemd/system/irq-affinity.service << EOL
[Unit]
Description=IRQ Affinity Optimization
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "for i in \$(grep nvidia /proc/interrupts | cut -d: -f1); do echo mask > /proc/irq/\$i/smp_affinity_list; done"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOL'

sudo systemctl enable irq-affinity.service

echo "System optimizations applied. A reboot is required for all changes to take effect."
echo "After reboot, verify settings with: nvidia-smi and cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor" 