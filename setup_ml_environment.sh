#!/bin/bash

echo "Setting up ML Environment and updating system..."

# Update system and NVIDIA drivers
echo "Updating system packages and NVIDIA drivers..."
sudo apt update
sudo apt upgrade -y

# Install NVIDIA and system packages
sudo apt install -y \
    nvidia-driver-550 \
    nvidia-settings \
    nvidia-utils-550 \
    nvidia-cuda-toolkit \
    nvidia-cuda-toolkit-gcc \
    ffmpeg \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    cmake \
    git \
    libopenexr-dev \
    libopencv-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    v4l-utils \
    libtbb-dev \
    libeigen3-dev \
    libatlas-base-dev \
    gfortran \
    ocl-icd-opencl-dev \
    opencl-headers \
    clinfo

# Create ML and Video Processing virtual environment
echo "Creating Python virtual environment..."
python3 -m venv ~/ml_env

# Activate virtual environment and install packages
echo "Installing packages..."
source ~/ml_env/bin/activate

# Upgrade pip and install basic tools
pip install --upgrade pip
pip install --upgrade setuptools wheel

# Install ML and video processing packages
pip install --upgrade \
    numpy \
    pandas \
    scipy \
    matplotlib \
    scikit-learn \
    scikit-image \
    jupyter \
    ipykernel \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    tensorflow[gpu] \
    tensorboard \
    h5py \
    tqdm \
    pillow \
    opencv-python \
    opencv-contrib-python \
    moviepy \
    av \
    imageio \
    imageio-ffmpeg \
    pyOpenEXR \
    OpenEXR \
    pycuda \
    cupy-cuda12x

# Register the virtual environment with Jupyter
python -m ipykernel install --user --name=ml_env --display-name="Python ML & Video"

# Create optimization script for video processing
echo "Creating video processing optimizations..."
sudo bash -c 'cat > /etc/profile.d/video-optimizations.sh << EOL
# Video Processing Optimizations
export OPENCV_OPENCL_DEVICE=0
export OPENCV_OPENCL_RUNTIME=NVIDIA
export CUDA_CACHE_MAXSIZE=2147483648  # 2GB cache for CUDA
export OPENCV_FFMPEG_CAPTURE_OPTIONS="video_codec;h264_cuvid,hwaccel;cuda,rtsp_transport;tcp"
export OPENCV_VIDEOWRITER_PROP_QUALITY=100
export AV_LOG_LEVEL=quiet
export IMAGEIO_FFMPEG_EXE=/usr/bin/ffmpeg
EOL'

# Create combined activation script
echo "Creating environment activation script..."
cat > ~/activate_ml_env.sh << 'EOL'
#!/bin/bash
source ~/ml_env/bin/activate
source /etc/profile.d/ml-optimizations.sh
source /etc/profile.d/video-optimizations.sh

# Print environment info
echo "ML & Video Environment Status:"
echo "============================="
python --version
echo -e "\nPackage Versions:"
pip list | grep -E "torch|tensorflow|numpy|cuda|opencv|ffmpeg|av"
echo -e "\nGPU Status:"
nvidia-smi
echo -e "\nFFmpeg Version:"
ffmpeg -version | head -n1
echo -e "\nOpenCL Devices:"
clinfo | grep -A 2 "Device Name"
EOL

chmod +x ~/activate_ml_env.sh

# Configure FFmpeg for GPU acceleration
sudo bash -c 'cat > /etc/environment.d/ffmpeg.conf << EOL
FFREPORT=file=/tmp/ffreport-%p-%t.log:level=32
CUDA_VISIBLE_DEVICES=0
EOL'

echo "Installation complete!"
echo "To activate the environment, run: source ~/activate_ml_env.sh"
echo "Please reboot your system to ensure all driver updates are properly applied."
echo -e "\nNote: The RTX 3090 is configured for both compute and video processing acceleration."
echo "The GTX 980 Ti remains dedicated to display output." 