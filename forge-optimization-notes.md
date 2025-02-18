# Stable Diffusion WebUI Forge Optimization Notes

## Tested Configurations

### Working Base Configuration
```bash
export COMMANDLINE_ARGS="--cuda-malloc \
                        --xformers \
                        --opt-split-attention \
                        --opt-channelslast \
                        --no-half-vae \
                        --enable-insecure-extension-access \
                        --api"
```

### Problematic Flags
- `--use-cuda-dsa`: Not supported in current version
- `--all-in-fp32`: Caused CUDA kernel issues
- `--force-enable-xformers`: May be redundant with `--xformers`

## Environment Variables Impact

### Memory Management
- `PYTORCH_CUDA_ALLOC_CONF="max_split_size_mb:512"`: Controls memory splitting
- `CUDA_MEMORY_FRACTION=0.95`: Controls VRAM allocation
- `MALLOC_TRIM_THRESHOLD_=0`: System memory optimization
- `MALLOC_MMAP_THRESHOLD_=0`: Memory mapping threshold

### CUDA Optimization
- `CUDA_LAUNCH_BLOCKING=1`: Debug mode, may impact performance
- `CUDA_MODULE_LOADING=LAZY`: Improves startup time
- `CUDA_CACHE_DISABLE=0`: Enables CUDA caching
- `CUDA_AUTO_BOOST=1`: Enables GPU boost

### PyTorch Settings
- `TORCH_CUDNN_V8_API_ENABLED=1`: Enables cuDNN v8 API
- `TORCH_ALLOW_TF32=1`: Enables TensorFloat-32
- `TORCH_CUDNN_BENCHMARK=1`: Enables cuDNN benchmarking

## Performance Metrics

### Base Configuration
- Startup time: ~8.4s
- Model loading: ~2.6s
- VRAM Usage: 95.78% weights, 4.22% computation

### Optimized Configuration
- Startup time: ~10.9s
- Model loading: ~1.4s
- VRAM Usage: Same as base

## Known Issues

1. CUDA Kernel Error
   ```
   RuntimeError: CUDA error: no kernel image is available for execution on the device
   ```
   - Occurs during text encoder position embedding conversion
   - May be related to PyTorch 2.3.1 compatibility
   - Not resolved by CUDA debugging flags

2. Memory Management
   - `pin_shared_memory` remains False despite configuration attempts
   - May impact transfer speeds between CPU and GPU

## Testing Procedure

1. Start with base configuration
2. Add optimizations one at a time:
   ```bash
   # Step 1: Base CUDA
   --cuda-malloc
   
   # Step 2: Memory Management
   --opt-channelslast
   --no-half-vae
   
   # Step 3: Performance
   --xformers
   --opt-split-attention
   
   # Step 4: Additional Optimizations
   --max-batch-count 8
   --disable-nan-check
   ```

3. Test after each addition
4. Document any errors or performance changes

## Reference Configurations

### Working A1111 Configuration
```bash
--no-download-sd-model --xformers --no-half-vae --api
```

### Forge Optimized Configuration
See `webui-user-forge-optimized.sh` for full configuration 