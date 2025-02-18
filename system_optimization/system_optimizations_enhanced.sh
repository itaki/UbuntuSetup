#!/bin/bash

# System Optimizations for AI/Video Workstation
# RTX 3090 - Compute GPU
# GTX 980 Ti - Display GPU
# Optimized for ProRes and OpenEXR workflows

echo "Applying system optimizations for AI/Video workstation..."

# Fix NVIDIA driver mismatch
echo "Updating NVIDIA drivers..."
sudo apt update
sudo apt install -y nvidia-driver-550 nvidia-utils-550

# Install video codec and EXR dependencies
echo "Installing ProRes and OpenEXR dependencies..."
sudo apt install -y \
    ffmpeg \
    libopenexr-dev \
    openexr \
    openexr-viewers \
    libaom-dev \
    libx264-dev \
    libx265-dev \
    libvpx-dev \
    libfdk-aac-dev \
    nasm \
    yasm

# System memory optimizations
echo "Configuring memory settings..."
sudo bash -c 'cat > /etc/sysctl.d/99-memory-optimizations.conf << EOL
# Reduce swappiness since we have 128GB RAM
vm.swappiness=10

# Optimize dirty ratio for better I/O performance with large media files
vm.dirty_ratio=40
vm.dirty_background_ratio=10
vm.dirty_expire_centisecs=6000
vm.dirty_writeback_centisecs=500

# Virtual memory optimizations
vm.vfs_cache_pressure=50
vm.page_cluster=0

# Enable huge pages for ML workloads and EXR handling
vm.nr_hugepages=2048

# File system optimizations
fs.file-max=2097152
fs.inotify.max_user_watches=524288

# Network optimizations for data transfer
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216

# IO optimizations for large media files
vm.max_map_count=262144
EOL'

# GPU Driver and Power Management
echo "Configuring GPU driver settings..."
sudo bash -c 'cat > /etc/modprobe.d/nvidia-power-management.conf << EOL
# Enable persistence mode and maximum performance for RTX 3090
options nvidia "NVreg_PreserveVideoMemoryAllocations=1" "NVreg_TemporaryFilePath=/var/tmp" "NVreg_EnableS0ixPowerManagement=0"
EOL'

# Configure dual GPU setup
echo "Configuring display GPU..."
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

# ML Framework Optimizations
echo "Configuring ML framework optimizations..."
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

# GPU Performance Service
echo "Configuring GPU performance service..."
sudo bash -c 'cat > /etc/systemd/system/gpu-optimize.service << EOL
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

# CPU Performance Service
echo "Configuring CPU performance service..."
sudo bash -c 'cat > /etc/systemd/system/cpu-optimize.service << EOL
[Unit]
Description=CPU Performance Optimization
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g performance
ExecStart=/usr/bin/bash -c "echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
ExecStart=/usr/bin/bash -c "echo 3 > /proc/sys/kernel/perf_event_paranoid"
ExecStart=/usr/bin/bash -c "echo 0 > /proc/sys/kernel/numa_balancing"
ExecStart=/usr/bin/bash -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"
ExecStart=/usr/bin/bash -c "echo 32768 > /proc/sys/vm/max_map_count"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOL'

# I/O Scheduler optimization
echo "Configuring I/O scheduler..."
sudo bash -c 'cat > /etc/udev/rules.d/60-scheduler.rules << EOL
# Set scheduler to mq-deadline for NVMe SSDs
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="mq-deadline"
# Set scheduler to bfq for SATA SSDs
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="bfq"
# Increase read-ahead for media drives
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/read_ahead_kb}="8192"
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/read_ahead_kb}="8192"
EOL'

# Create cache directories
sudo mkdir -p /tmp/cuda-cache /tmp/torch-extensions /tmp/prores_cache /tmp/exr_cache
sudo chmod 1777 /tmp/cuda-cache /tmp/torch-extensions /tmp/prores_cache /tmp/exr_cache

# Set up IRQ affinity
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

# Configure FFmpeg for ProRes
echo "Configuring FFmpeg optimizations..."
sudo bash -c 'cat > /etc/profile.d/video-optimizations.sh << EOL
# FFmpeg optimization for ProRes
export FFREPORT=file=/tmp/ffreport-%p-%t.log:level=32
export CUDA_VISIBLE_DEVICES=0
export FFMPEG_CUDA_DEVICE=0

# OpenEXR optimization
export OPENEXR_THREADING_LEVEL=2
export OPENEXR_IMF_MAX_MEMORY=8589934592  # 8GB for EXR operations
export OPENEXR_IMF_THREAD_POOL=32  # Match your CPU thread count

# General media processing
export MAGICK_OCL_DEVICE=NVIDIA
export MAGICK_THREAD_LIMIT=32
export OMP_NUM_THREADS=32

# GPU decode/encode preferences
export OPENCV_FFMPEG_CAPTURE_OPTIONS="video_codec;h264_cuvid,hwaccel;cuda,rtsp_transport;tcp"
export OPENCV_VIDEOWRITER_PROP_QUALITY=100
EOL'

# Source both optimization files in profile
sudo bash -c 'cat > /etc/profile.d/load-optimizations.sh << EOL
#!/bin/bash
source /etc/profile.d/ml-optimizations.sh
source /etc/profile.d/video-optimizations.sh
EOL'

# Make sure the profile script is executable
sudo chmod +x /etc/profile.d/load-optimizations.sh

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable cpu-optimize.service
sudo systemctl enable gpu-optimize.service
sudo systemctl enable irq-affinity.service

# Apply sysctl settings
sudo sysctl -p /etc/sysctl.d/99-memory-optimizations.conf

echo "System optimizations applied. Please reboot your system for changes to take effect."
echo "After reboot, run 'source /etc/profile.d/load-optimizations.sh' or log out and back in for all optimizations to take effect."
echo -e "\nNote: The RTX 3090 is configured for compute and the GTX 980 Ti for display output."
echo "ProRes and OpenEXR optimizations are enabled with GPU acceleration where possible." 