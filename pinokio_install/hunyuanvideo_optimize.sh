#!/bin/bash

# HunyuanVideo optimization script for high VRAM GPUs
# This script optimizes HunyuanVideo to use more VRAM on high-end GPUs

echo "Starting HunyuanVideo optimization for high VRAM GPUs..."

# Define paths
PINOKIO_DIR="$HOME/pinokio"
HUNYUAN_DIR="$PINOKIO_DIR/api/hunyuanvideo.git"
APP_DIR="$HUNYUAN_DIR/app"
CONFIG_FILE="$APP_DIR/gradio_config.json"
START_JS_FILE="$HUNYUAN_DIR/start.js"

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

# Check if the config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    echo "Please make sure HunyuanVideo is installed correctly."
    exit 1
fi

# Check if the start.js file exists
if [ ! -f "$START_JS_FILE" ]; then
    echo "Error: start.js file not found at $START_JS_FILE"
    echo "Please make sure HunyuanVideo is installed correctly."
    exit 1
fi

# Backup the current config file
echo "Backing up the current config file..."
BACKUP_FILE="$CONFIG_FILE.bak"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Config file backed up to $BACKUP_FILE"

# Backup the current start.js file
echo "Backing up the current start.js file..."
START_JS_BACKUP="$START_JS_FILE.bak"
cp "$START_JS_FILE" "$START_JS_BACKUP"
echo "start.js file backed up to $START_JS_BACKUP"

# Update the config file for high VRAM GPUs
echo "Updating the config file for high VRAM GPUs..."
cat > "$CONFIG_FILE" << EOL
{"attention_mode": "auto", "transformer_filename": "ckpts/hunyuan-video-t2v-720p/transformers/hunyuan_video_720_bf16.safetensors", "transformer_filename_i2v": "ckpts/hunyuan-video-t2v-720p/transformers/hunyuan_video_720_bf16.safetensors", "text_encoder_filename": "ckpts/text_encoder/llava-llama-3-8b-v1_1_fp16.safetensors", "compile": "", "default_ui": "t2v", "vae_config": 0, "profile": 1}
EOL

# Update the start.js file to use profile 1 instead of 4
echo "Updating the start.js file to use profile 1..."
sed -i 's/--profile {{args.profile}}/--profile 1/g' "$START_JS_FILE"

echo "Config file and start.js updated successfully!"
echo "Changes made:"
echo "1. Changed memory profile from LowRAM_LowVRAM (4) to HighRAM_HighVRAM (1)"
echo "2. Changed transformer model from quantized (int8) to full precision (bf16)"
echo "3. Changed text encoder model from quantized (int8) to full precision (fp16)"
echo "4. Modified start.js to use profile 1 instead of using the args.profile parameter"

echo "To revert these changes, run:"
echo "cp \"$BACKUP_FILE\" \"$CONFIG_FILE\""
echo "cp \"$START_JS_BACKUP\" \"$START_JS_FILE\""

echo "HunyuanVideo optimization completed successfully!"
echo "Please restart HunyuanVideo from Pinokio to apply these changes." 