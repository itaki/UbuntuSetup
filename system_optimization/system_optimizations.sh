#!/bin/bash

# System Optimizations for AI Workstation
# RTX 3090 - Compute GPU
# GTX 980 Ti - Display GPU

echo "Applying system optimizations for AI workstation..."

# Memory Management Optimizations
echo "Applying memory optimizations..."
sudo bash -c 'cat > /etc/sysctl.d/99-memory-optimizations.conf << EOL
# Reduce swappiness since we have 128GB RAM
vm.swappiness=10

# Optimize dirty ratio for better I/O performance
vm.dirty_ratio=30
vm.dirty_background_ratio=5

# Virtual memory tweaks
vm.vfs_cache_pressure=50
vm.page_cluster=0

# Enable huge pages for ML workloads
vm.nr_hugepages=2048
EOL'

# GPU Optimizations
echo "Configuring GPU settings..."

# Create GPU config file
sudo bash -c 'cat > /etc/modprobe.d/nvidia-power-management.conf << EOL
# Enable persistence mode and maximum performance for RTX 3090
options nvidia "NVreg_PreserveVideoMemoryAllocations=1" "NVreg_TemporaryFilePath=/var/tmp" "NVreg_EnableS0ixPowerManagement=0"
EOL'

# Create separate X11 configuration for each GPU
sudo bash -c 'cat > /etc/X11/xorg.conf.d/10-nvidia-primary.conf << EOL
Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    VendorName     "NVIDIA Corporation"
    BusID          "PCI:34:0:0"  # GTX 980 Ti - Display
    Option         "UseDisplayDevice" "DFP"
    Option         "AllowEmptyInitialConfiguration" "True"
EndSection
EOL'

# Configure CUDA and ML Framework Optimizations
sudo bash -c 'cat > /etc/profile.d/ml-optimizations.sh << EOL
# CUDA Configuration
export CUDA_VISIBLE_DEVICES="0"
export CUDA_CACHE_PATH="/tmp/cuda-cache"
export CUDA_AUTO_BOOST=0

# PyTorch Optimizations
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:512
export TORCH_CUDA_ARCH_LIST="8.6"  # RTX 3090 architecture
export TORCH_EXTENSIONS_DIR="/tmp/torch-extensions"
export TORCH_DISTRIBUTED_DEBUG=INFO
export TORCH_SHOW_CPP_STACKTRACES=1

# TensorFlow Optimizations
export TF_FORCE_GPU_ALLOW_GROWTH=true
export TF_GPU_THREAD_MODE=gpu_private
export TF_GPU_THREAD_COUNT=1
export TF_XLA_FLAGS="--tf_xla_auto_jit=2 --tf_xla_cpu_global_jit"
export TF_ENABLE_ONEDNN_OPTS=1
export TF_CPP_MIN_LOG_LEVEL=2

# General ML Performance
export NCCL_P2P_DISABLE=0
export NCCL_IB_DISABLE=1
export OMP_NUM_THREADS=32
export MKL_NUM_THREADS=32
EOL'

# Create systemd service for GPU optimization
sudo bash -c 'cat > /etc/systemd/system/gpu-optimize.service << EOL
[Unit]
Description=GPU Optimization Service
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pm 1
ExecStart=/usr/bin/nvidia-smi -i 0 -pl 370  # Set power limit for RTX 3090
ExecStart=/usr/bin/nvidia-smi -i 0 --compute-mode=0  # Set compute mode for RTX 3090
ExecStart=/usr/bin/nvidia-smi -i 0 --applications-clocks=1410,1695  # Memory and Graphics clocks for RTX 3090
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOL'

# CPU Governor and IRQ Settings
echo "Configuring CPU settings..."
sudo bash -c 'cat > /etc/systemd/system/cpu-optimize.service << EOL
[Unit]
Description=CPU Optimization Service
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g performance
ExecStart=/usr/bin/bash -c "echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
# Set CPU affinity for better NUMA optimization
ExecStart=/usr/bin/bash -c "echo 3 > /proc/sys/kernel/perf_event_paranoid"
ExecStart=/usr/bin/bash -c "echo 0 > /proc/sys/kernel/numa_balancing"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOL'

# Create cache directories
sudo mkdir -p /tmp/cuda-cache /tmp/torch-extensions
sudo chmod 1777 /tmp/cuda-cache /tmp/torch-extensions

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable gpu-optimize.service
sudo systemctl enable cpu-optimize.service

# Apply sysctl changes
sudo sysctl -p /etc/sysctl.d/99-memory-optimizations.conf

echo "System optimizations applied. Please reboot your system for changes to take effect."
echo "After reboot, run 'source /etc/profile.d/ml-optimizations.sh' or log out and back in for ML framework optimizations to take effect." 