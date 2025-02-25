#!/bin/bash
export COMMANDLINE_ARGS="--device-id 0 --cuda-malloc --cuda-stream --xformers --xformers-flash-attention --opt-sdp-attention --opt-channelslast --precision full --enable-insecure-extension-access --api --max-batch-count 8 --disable-model-loading-ram-optimization --always-high-vram --disable-nan-check --no-progressbar-hiding --skip-torch-cuda-test --force-enable-xformers --no-half-vae --use-fp16-for-online-loras"
export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4"
export TCMALLOC_LARGE_ALLOC_REPORT_THRESHOLD=1073741824
export TCMALLOC_RELEASE_RATE=10.0
export CUDA_VISIBLE_DEVICES=0
export PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:4096,garbage_collection_threshold:0.9,roundup_power2:True,expandable_segments:True,backend:cudaMallocAsync"
export TORCH_ALLOW_TF32=1
export TORCH_CUDNN_BENCHMARK=1
export TORCH_CUDNN_V8_API_ENABLED=1
mkdir -p /dev/shm/sd_cache /dev/shm/cuda_cache /dev/shm/torch_extensions
