#!/bin/bash

# Forge Incremental Testing Script
# This script helps test Forge optimizations incrementally

# Base directory for the webui-user.sh
FORGE_DIR="/home/mm/pinokio/api/stable-diffusion-webui-forge.git/app"
BACKUP_FILE="${FORGE_DIR}/webui-user.sh.backup"

# Test configurations
declare -A CONFIGS=(
    ["base"]="--xformers --enable-insecure-extension-access --api"
    ["cuda"]="--cuda-malloc --xformers --enable-insecure-extension-access --api"
    ["memory"]="--cuda-malloc --xformers --opt-channelslast --no-half-vae --enable-insecure-extension-access --api"
    ["performance"]="--cuda-malloc --xformers --opt-channelslast --no-half-vae --opt-split-attention --enable-insecure-extension-access --api"
    ["full"]="--device-id 0 --cuda-malloc --cuda-stream --xformers --xformers-flash-attention --opt-sdp-attention --opt-channelslast --precision full --enable-insecure-extension-access --api --max-batch-count 8 --disable-model-loading-ram-optimization --always-high-vram --disable-nan-check --no-progressbar-hiding --skip-torch-cuda-test --force-enable-xformers"
)

# Environment variable sets
declare -A ENV_VARS=(
    ["base"]=""
    ["cuda"]="export CUDA_MODULE_LOADING=LAZY
export CUDA_CACHE_DISABLE=0
export CUDA_CACHE_PATH=\"/dev/shm/cuda_cache\""
    ["memory"]="export CUDA_MODULE_LOADING=LAZY
export CUDA_CACHE_DISABLE=0
export CUDA_CACHE_PATH=\"/dev/shm/cuda_cache\"
export PYTORCH_CUDA_ALLOC_CONF=\"max_split_size_mb:512\""
    ["full"]="export MALLOC_TRIM_THRESHOLD_=0
export MALLOC_MMAP_THRESHOLD_=0
export PYTHONMALLOC=malloc
export CUDA_AUTO_BOOST=1
export CUDA_FORCE_PTX_JIT=1
export CUDA_MODULE_LOADING=LAZY
export CUDA_CACHE_DISABLE=0
export CUDA_CACHE_PATH=\"/dev/shm/cuda_cache\"
export CUDA_DEVICE_MAX_CONNECTIONS=1
export PYTORCH_CUDA_ALLOC_CONF=\"max_split_size_mb:512\"
export TORCH_ALLOW_TF32=1
export CUDA_LAUNCH_BLOCKING=0
export TORCH_CUDNN_V8_API_ENABLED=1
export TORCH_CUDNN_BENCHMARK=1"
)

# Function to create webui-user.sh with specific configuration
create_config() {
    local config_name=$1
    local args=${CONFIGS[$config_name]}
    local env_vars=${ENV_VARS[$config_name]}
    
    # Create the configuration file
    cat > "${FORGE_DIR}/webui-user.sh" << EOL
#!/bin/bash
#########################################################
# Test Configuration: ${config_name}
#########################################################

# Command line arguments
export COMMANDLINE_ARGS="${args}"

# Environment variables
${env_vars}

# Create cache directories
mkdir -p /dev/shm/sd_cache
mkdir -p /dev/shm/cuda_cache

###########################################
EOL
    
    chmod +x "${FORGE_DIR}/webui-user.sh"
}

# Function to run test
run_test() {
    local config_name=$1
    echo "Testing configuration: ${config_name}"
    echo "----------------------------------------"
    create_config "${config_name}"
    
    # Run Forge
    cd "${FORGE_DIR}"
    ./webui.sh -f
    
    echo "----------------------------------------"
    echo "Test complete for ${config_name}"
    echo "Press Enter to continue to next test..."
    read
}

# Main menu
while true; do
    clear
    echo "Forge Incremental Testing"
    echo "========================"
    echo "1) Test Base Configuration"
    echo "2) Test CUDA Optimization"
    echo "3) Test Memory Optimization"
    echo "4) Test Performance Optimization"
    echo "5) Test Full Optimization"
    echo "6) Restore Original Backup"
    echo "7) Exit"
    echo
    read -p "Select an option: " choice
    
    case $choice in
        1) run_test "base";;
        2) run_test "cuda";;
        3) run_test "memory";;
        4) run_test "performance";;
        5) run_test "full";;
        6) 
            if [ -f "$BACKUP_FILE" ]; then
                cp "$BACKUP_FILE" "${FORGE_DIR}/webui-user.sh"
                echo "Restored original backup"
            else
                echo "No backup file found"
            fi
            read -p "Press Enter to continue..."
            ;;
        7) exit 0;;
        *) echo "Invalid option";;
    esac
done 