#!/bin/bash
#########################################################
# Optimized configuration for Stable Diffusion WebUI Forge
# This configuration includes performance optimizations for:
# - CUDA memory management
# - PyTorch operations
# - System resource utilization
#########################################################

# Command line arguments
export COMMANDLINE_ARGS="--device-id 0 \
                        --cuda-malloc \
                        --cuda-stream \
                        --xformers \
                        --xformers-flash-attention \
                        --opt-sdp-attention \
                        --opt-channelslast \
                        --precision full \
                        --enable-insecure-extension-access \
                        --api \
                        --max-batch-count 8 \
                        --disable-model-loading-ram-optimization \
                        --always-high-vram \
                        --disable-nan-check \
                        --no-progressbar-hiding \
                        --skip-torch-cuda-test \
                        --force-enable-xformers"

# System optimizations
export MALLOC_TRIM_THRESHOLD_=0
export MALLOC_MMAP_THRESHOLD_=0
export PYTHONMALLOC=malloc
export CUDA_AUTO_BOOST=1
export CUDA_FORCE_PTX_JIT=1
export CUDA_MODULE_LOADING=LAZY
export CUDA_CACHE_DISABLE=0
export CUDA_CACHE_PATH="/dev/shm/cuda_cache"
export CUDA_DEVICE_MAX_CONNECTIONS=1
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:512"
export TORCH_ALLOW_TF32=1
export CUDA_LAUNCH_BLOCKING=0
export TORCH_CUDNN_V8_API_ENABLED=1
export TORCH_CUDNN_BENCHMARK=1

# Force single GPU mode
export CUDA_VISIBLE_DEVICES=0

# Configure accelerate
export ACCELERATE="True"
export ACCELERATE_CONFIG_FILE="accelerate_config.yaml"

# Create accelerate config if it doesn't exist
if [ ! -f "accelerate_config.yaml" ]; then
    cat > "accelerate_config.yaml" << EOL
compute_environment: LOCAL_MACHINE
distributed_type: 'NO'
downcast_bf16: 'no'
gpu_ids: '0'
machine_rank: 0
main_training_function: main
mixed_precision: 'no'
num_machines: 1
num_processes: 1
rdzv_backend: static
same_network: true
tpu_env: []
tpu_use_cluster: false
use_cpu: false
dynamo_backend: 'no'
megatron_lm_tp_degree: 1
megatron_lm_pp_degree: 1
megatron_lm_sequence_parallelism: false
deepspeed_config: {}
fsdp_config: {}
EOL
fi

# Create cache directories
mkdir -p /dev/shm/sd_cache
mkdir -p /dev/shm/cuda_cache

########################################### 