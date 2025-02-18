#!/bin/bash
#########################################################
# Uncomment and change the variables below to your need:#
#########################################################

# Install directory without trailing slash
#install_dir="/home/$(whoami)"

# Name of the subdirectory
#clone_dir="stable-diffusion-webui"

# Commandline arguments for webui.py
export COMMANDLINE_ARGS="--xformers \
                        --cuda-malloc \
                        --cuda-stream \
                        --opt-channelslast \
                        --no-half-vae \
                        --no-half \
                        --no-half-model \
                        --no-download-sd-model \
                        --enable-insecure-extension-access \
                        --device-id 0 \
                        --pin-shared-memory \
                        --always-high-vram \
                        --skip-torch-cuda-test \
                        --skip-python-version-check \
                        --opt-sdp-attention \
                        --opt-sub-quad-attention \
                        --opt-split-attention-v1 \
                        --disable-nan-check \
                        --no-progress-bars \
                        --disable-safe-unpickle \
                        --api"

# python3 executable
#python_cmd="python3"

# git executable
#export GIT="git"

# python3 venv without trailing slash (defaults to ${install_dir}/${clone_dir}/venv)
#venv_dir="venv"

# script to launch to start the app
#export LAUNCH_SCRIPT="launch.py"

# install command for torch
#export TORCH_COMMAND="pip install torch==1.12.1+cu113 --extra-index-url https://download.pytorch.org/whl/cu113"

# Requirements file to use for stable-diffusion-webui
#export REQS_FILE="requirements_versions.txt"

# Fixed git repos
#export K_DIFFUSION_PACKAGE=""
#export GFPGAN_PACKAGE=""

# Fixed git commits
#export STABLE_DIFFUSION_COMMIT_HASH=""
#export CODEFORMER_COMMIT_HASH=""
#export BLIP_COMMIT_HASH=""

# Enable accelerated launch with config
export ACCELERATE="True"
export ACCELERATE_CONFIG_FILE="accelerate_config.yaml"

# Force single GPU
export CUDA_VISIBLE_DEVICES=0

# CUDA optimizations
export CUDA_MODULE_LOADING=LAZY
export CUDA_CACHE_DISABLE=0
export CUDA_CACHE_PATH="/dev/shm/cuda_cache"
export CUDA_CACHE_MAXSIZE=4294967296
export CUDA_DEVICE_MAX_CONNECTIONS=1
export CUDA_LAUNCH_BLOCKING=0
export CUDA_FORCE_PTX_JIT=1
export CUDA_AUTO_BOOST=1
export CUDA_MEMORY_POOL_INIT_SIZE=2048
export CUDA_DEVICE_DEFAULT_PERSISTING_L2=1
export CUDA_FORCE_WAVE64=1
export CUDA_JIT_USE_FAST_MATH=1
export CUDA_FORCE_COMPRESSED_SPILL=1
export CUDA_MANAGED_FORCE_DEVICE_ALLOC=1
export CUDA_VIRTUAL_MEMORY_COMPRESSION=1

# PyTorch optimizations
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:4096,garbage_collection_threshold:0.9,roundup_power2:True,expandable_segments:True,backend:cudaMallocAsync"
export PYTORCH_NO_CUDA_MEMORY_CACHING=0
export TORCH_ALLOW_TF32=1
export TORCH_CUDNN_BENCHMARK=1
export TORCH_USE_CUDA_DSA=0
export TORCH_CUDNN_V8_API_ENABLED=1
export TORCH_DISTRIBUTED_DEBUG=OFF
export TORCH_CPP_LOG_LEVEL=ERROR
export TORCH_SHOW_CPP_STACKTRACES=0
export TORCH_EXTENSIONS_DIR=/dev/shm/torch_extensions

# System optimizations
export MALLOC_TRIM_THRESHOLD_=0
export MALLOC_MMAP_THRESHOLD_=0
export PYTHONMALLOC=malloc

# Create cache directories
mkdir -p /dev/shm/sd_cache
mkdir -p /dev/shm/cuda_cache
mkdir -p /dev/shm/torch_extensions

########################################### 