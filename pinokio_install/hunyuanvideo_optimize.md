# HunyuanVideo Optimization for High VRAM GPUs

This document explains how to optimize HunyuanVideo for high VRAM GPUs (24GB+).

## Background

HunyuanVideo uses a memory management system called "Memory Management for the GPU Poor" (mmgp) developed by DeepBeepMeep. This system is designed to allow large AI models to run on consumer GPUs with limited VRAM.

By default, HunyuanVideo is configured to run on systems with minimal resources (6GB VRAM, 24GB RAM). However, if you have a high-end GPU with 24GB of VRAM (like an RTX 3090 or RTX 4090), you can optimize the configuration to:

1. Use more VRAM for better performance
2. Use full precision models for better quality
3. Reduce model swapping for faster generation

## Memory Profiles

The mmgp system has 5 different memory profiles:

1. `HighRAM_HighVRAM` (profile 1): For systems with high RAM (48GB+) and high VRAM (24GB)
2. `HighRAM_LowVRAM` (profile 2): For systems with high RAM but low VRAM
3. `LowRAM_HighVRAM` (profile 3): For systems with low RAM but high VRAM
4. `LowRAM_LowVRAM` (profile 4): For systems with low RAM and low VRAM (default)
5. `VerylowRAM_LowVRAM` (profile 5): For systems with very low RAM and low VRAM

## Model Precision

HunyuanVideo can use different precision models:

1. Full precision (bf16/fp16): Better quality but requires more VRAM
2. Quantized (int8): Lower quality but requires less VRAM

## Optimization Process

The `hunyuanvideo_optimize.sh` script makes the following changes:

1. Changes the memory profile from `LowRAM_LowVRAM` (4) to `HighRAM_HighVRAM` (1)
2. Changes the transformer model from quantized (int8) to full precision (bf16)
3. Changes the text encoder model from quantized (int8) to full precision (fp16)
4. Modifies the Pinokio start.js file to use profile 1 instead of the default profile 4

These changes allow HunyuanVideo to use more of your available VRAM, which should result in:

- Faster video generation
- Better quality videos
- Less model swapping during generation

## Why Modify start.js?

In Pinokio, the start.js file controls how HunyuanVideo is launched. By default, it passes the `--profile 4` argument to the gradio_server.py script, which overrides the settings in the gradio_config.json file. By modifying start.js to use `--profile 1` instead, we ensure that our high VRAM optimization is actually applied.

## Usage

1. Run the optimization script:

```bash
./pinokio_install/hunyuanvideo_optimize.sh
```

2. Restart HunyuanVideo from Pinokio

## Reverting Changes

If you encounter any issues after optimization, you can revert to the default configuration:

```bash
cp "/home/mm/pinokio/api/hunyuanvideo.git/app/gradio_config.json.bak" "/home/mm/pinokio/api/hunyuanvideo.git/app/gradio_config.json"
cp "/home/mm/pinokio/api/hunyuanvideo.git/start.js.bak" "/home/mm/pinokio/api/hunyuanvideo.git/start.js"
```

## Notes

- This optimization is only recommended for systems with 24GB+ VRAM
- If you have less than 48GB of system RAM, you might want to use profile 3 (`LowRAM_HighVRAM`) instead
- The full precision models provide better quality but may be slightly slower than the quantized models
- You can monitor your GPU memory usage with tools like `nvidia-smi` to see how much VRAM is being used after optimization 