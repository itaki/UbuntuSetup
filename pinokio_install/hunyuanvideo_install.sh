#!/bin/bash

# HunyuanVideo installation script for Pinokio
# This script fixes the installation issues with HunyuanVideo in Pinokio

echo "Starting HunyuanVideo installation fix..."

# Define paths
PINOKIO_DIR="$HOME/pinokio"
HUNYUAN_DIR="$PINOKIO_DIR/api/hunyuanvideo.git"
APP_DIR="$HUNYUAN_DIR/app"
CONDA_DIR="$PINOKIO_DIR/bin/miniconda"
CONDA_BIN="$CONDA_DIR/bin/conda"

# Check if the Pinokio directory exists
if [ ! -d "$PINOKIO_DIR" ]; then
    echo "Error: Pinokio directory not found at $PINOKIO_DIR"
    echo "Please make sure Pinokio is installed correctly."
    exit 1
fi

# Check if the HunyuanVideo directory exists
if [ ! -d "$HUNYUAN_DIR" ]; then
    echo "Error: HunyuanVideo directory not found at $HUNYUAN_DIR"
    echo "Please install HunyuanVideo from Pinokio first."
    exit 1
fi

# Check if conda exists
if [ ! -f "$CONDA_BIN" ]; then
    echo "Error: Conda not found at $CONDA_BIN"
    echo "Please make sure Pinokio is installed correctly."
    exit 1
fi

# Backup the current app directory
echo "Backing up the current app directory..."
BACKUP_DIR="$HUNYUAN_DIR/app_backup_$(date +%Y%m%d%H%M%S)"
mv "$APP_DIR" "$BACKUP_DIR"

# Clone the repository
echo "Cloning the HunyuanVideoGP repository..."
cd "$HUNYUAN_DIR"
git clone https://github.com/deepbeepmeep/HunyuanVideoGP app

# Setup conda environment
echo "Setting up the conda environment..."
cd "$APP_DIR"

# Add conda to PATH
export PATH="$CONDA_DIR/bin:$PATH"

# Initialize conda for bash shell
eval "$("$CONDA_BIN" shell.bash hook)"

# Create a new conda environment
echo "Creating conda environment..."
"$CONDA_BIN" create -y -n hunyuanvideo python=3.10

# Activate the conda environment
echo "Activating conda environment..."
source "$CONDA_DIR/bin/activate" hunyuanvideo

# Install dependencies
echo "Installing dependencies..."
"$CONDA_BIN" install -y pip
pip install --upgrade pip

# Install PyTorch with CUDA support first
echo "Installing PyTorch with CUDA support..."
pip install torch==2.6.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# Install the specific numpy version required
echo "Installing specific numpy version..."
pip install numpy==1.24.4

# Install other requirements
echo "Installing other requirements..."
pip install -r requirements.txt

# Install SageAttention with build isolation disabled
echo "Installing SageAttention..."
pip install git+https://github.com/thu-ml/SageAttention --no-build-isolation

# Install flash-attention if needed
echo "Installing flash-attention..."
pip install flash-attn==2.7.2.post1

# Create a symbolic link to the conda environment in the expected location
echo "Creating symbolic link to conda environment..."
mkdir -p "$APP_DIR/env/bin"

# Get the conda environment path
CONDA_ENV_PATH=$("$CONDA_BIN" env list | grep hunyuanvideo | awk '{print $2}')
echo "Conda environment path: $CONDA_ENV_PATH"

# Create symbolic links
ln -sf "$CONDA_ENV_PATH/bin/python" "$APP_DIR/env/bin/python"
ln -sf "$CONDA_ENV_PATH/bin/pip" "$APP_DIR/env/bin/pip"

# Create an activation script that Pinokio can use
echo "Creating activation script..."
cat > "$APP_DIR/env/bin/activate" << EOL
#!/bin/bash
# This script activates the conda environment for HunyuanVideo
export PATH="$CONDA_DIR/bin:\$PATH"
source "$CONDA_DIR/bin/activate" hunyuanvideo
EOL

# Make the activation script executable
chmod +x "$APP_DIR/env/bin/activate"

# Deactivate the conda environment
source "$CONDA_DIR/bin/deactivate"

echo "HunyuanVideo installation completed successfully!"
echo "You can now run HunyuanVideo from Pinokio." 