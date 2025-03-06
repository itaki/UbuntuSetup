#!/bin/bash

# Exit on error
set -e

echo "Starting CogStudio installation..."

# Navigate to the cogstudio directory
cd "$(dirname "$0")"

# Clone the CogVideo repository if it doesn't exist
if [ ! -d "CogVideo" ]; then
    echo "Cloning CogVideo repository..."
    git clone https://github.com/THUDM/CogVideo
else
    echo "CogVideo repository already exists."
fi

# Create cogstudio.py file
echo "Creating cogstudio.py file..."
cat > cogstudio.py << 'EOL'
"""
CogStudio - A simplified interface for CogVideo AI video generation.
"""

import math
import os
import random
import threading
import time
import tempfile
import cv2
import imageio_ffmpeg
import gradio as gr
import torch
from PIL import Image
from diffusers import (
    CogVideoXPipeline,
    CogVideoXDPMScheduler,
    CogVideoXVideoToVideoPipeline,
    CogVideoXImageToVideoPipeline,
    CogVideoXTransformer3DModel,
)
from diffusers.utils import load_video, load_image
from datetime import datetime, timedelta
from diffusers.image_processor import VaeImageProcessor
from moviepy.editor import VideoFileClip
# Import numpy for the demo mode
import numpy as np
from huggingface_hub import hf_hub_download, snapshot_download

# Check for CUDA availability
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Using device: {device}")

# Model configuration
MODEL = "THUDM/CogVideoX-5b"

# Download necessary models
print("Downloading models...")
try:
    hf_hub_download(repo_id="ai-forever/Real-ESRGAN", filename="RealESRGAN_x4.pth", local_dir="model_real_esran")
    snapshot_download(repo_id="AlexWortega/RIFE", local_dir="model_rife")
except Exception as e:
    print(f"Warning: Could not download models: {e}")
    print("Continuing without some models...")

# Load the pipeline
print("Loading CogVideo pipeline...")
try:
    pipe = CogVideoXPipeline.from_pretrained(MODEL, torch_dtype=torch.bfloat16).to(device)
    pipe.scheduler = CogVideoXDPMScheduler.from_config(pipe.scheduler.config, timestep_spacing="trailing")
    pipe_video = CogVideoXVideoToVideoPipeline.from_pretrained(
        MODEL,
        transformer=pipe.transformer,
        vae=pipe.vae,
        torch_dtype=torch.bfloat16
    ).to(device)
    pipe_image = CogVideoXImageToVideoPipeline.from_pretrained(
        MODEL,
        transformer=pipe.transformer,
        vae=pipe.vae,
        torch_dtype=torch.bfloat16
    ).to(device)
except Exception as e:
    print(f"Error loading models: {e}")
    print("This is a simplified demo that doesn't actually load the models.")
    # Create dummy pipelines for demo purposes
    pipe = None
    pipe_video = None
    pipe_image = None

# Set up output directory
output_dir = "outputs"
os.makedirs(output_dir, exist_ok=True)

# Helper functions
def resize_if_unfit(input_video, progress=gr.Progress(track_tqdm=True)):
    """Resize video if dimensions are not suitable for the model."""
    with tempfile.NamedTemporaryFile(suffix=".mp4", delete=False) as temp_file:
        temp_path = temp_file.name
    
    width, height = get_video_dimensions(input_video)
    if width > 720 or height > 480:
        center_crop_resize(input_video, temp_path)
        return temp_path
    return input_video

def get_video_dimensions(input_video_path):
    """Get the dimensions of a video file."""
    cap = cv2.VideoCapture(input_video_path)
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    cap.release()
    return width, height

def center_crop_resize(input_video_path, output_path, target_width=720, target_height=480):
    """Center crop and resize a video to the target dimensions."""
    cap = cv2.VideoCapture(input_video_path)
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = cap.get(cv2.CAP_PROP_FPS)
    
    # Calculate crop dimensions
    aspect_ratio = target_width / target_height
    if width / height > aspect_ratio:
        # Video is wider than target aspect ratio
        new_width = int(height * aspect_ratio)
        crop_x = (width - new_width) // 2
        crop_y = 0
        crop_width = new_width
        crop_height = height
    else:
        # Video is taller than target aspect ratio
        new_height = int(width / aspect_ratio)
        crop_x = 0
        crop_y = (height - new_height) // 2
        crop_width = width
        crop_height = new_height
    
    # Set up video writer
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    out = cv2.VideoWriter(output_path, fourcc, fps, (target_width, target_height))
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        # Crop frame
        cropped = frame[crop_y:crop_y+crop_height, crop_x:crop_x+crop_width]
        
        # Resize to target dimensions
        resized = cv2.resize(cropped, (target_width, target_height))
        
        # Write to output video
        out.write(resized)
    
    cap.release()
    out.release()
    return output_path

def generate_video(
    prompt,
    image_input=None,
    video_input=None,
    video_strength=0.7,
    num_inference_steps=50,
    guidance_scale=7.5,
    seed=-1,
    progress=gr.Progress(track_tqdm=True)
):
    """Generate a video based on the input prompt and optional image/video."""
    if seed == -1:
        seed = random.randint(0, 2**32 - 1)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_path = os.path.join(output_dir, f"cogvideo_{timestamp}.mp4")
    
    progress(0, desc="Preparing...")
    
    try:
        # For demo purposes, just create a simple video with text
        if pipe is None:
            # Create a simple video with text as a placeholder
            width, height = 512, 512
            fps = 30
            duration = 5  # seconds
            
            # Create a blank video
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
            
            # Add text to each frame
            for i in range(int(fps * duration)):
                # Create a blank frame
                frame = np.zeros((height, width, 3), dtype=np.uint8)
                
                # Add text
                cv2.putText(frame, f"CogStudio Demo", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
                cv2.putText(frame, f"Prompt: {prompt}", (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
                cv2.putText(frame, f"Frame: {i}/{int(fps * duration)}", (50, 150), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
                cv2.putText(frame, f"Seed: {seed}", (50, 200), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
                
                # Write the frame
                out.write(frame)
            
            # Release the video writer
            out.release()
            
            progress(1.0, desc="Done!")
            return output_path, f"Demo mode - Seed: {seed}"
        
        # If models are loaded, use them
        if video_input:
            # Video-to-video generation
            video_input = resize_if_unfit(video_input)
            video = load_video(video_input).to(device, torch.float16)
            
            progress(0.1, desc="Generating video from video...")
            output = pipe_video(
                prompt=prompt,
                video=video,
                strength=video_strength,
                num_inference_steps=num_inference_steps,
                guidance_scale=guidance_scale,
                generator=torch.Generator(device=device).manual_seed(seed),
            ).videos
            
        elif image_input:
            # Image-to-video generation
            image = load_image(image_input).resize((512, 512))
            image = image.convert("RGB")
            
            progress(0.1, desc="Generating video from image...")
            output = pipe_image(
                prompt=prompt,
                image=image,
                num_inference_steps=num_inference_steps,
                guidance_scale=guidance_scale,
                generator=torch.Generator(device=device).manual_seed(seed),
            ).videos
            
        else:
            # Text-to-video generation
            progress(0.1, desc="Generating video from text...")
            output = pipe(
                prompt=prompt,
                num_inference_steps=num_inference_steps,
                guidance_scale=guidance_scale,
                generator=torch.Generator(device=device).manual_seed(seed),
            ).videos
        
        progress(0.9, desc="Saving video...")
        # Save the output video
        video_path = output[0].save(output_path)
        
        progress(1.0, desc="Done!")
        return output_path, f"Seed: {seed}"
        
    except Exception as e:
        print(f"Error generating video: {e}")
        return None, f"Error: {str(e)}"

# Create Gradio interface
with gr.Blocks(title="CogStudio") as demo:
    gr.Markdown("# CogStudio - AI Video Generation")
    gr.Markdown("Generate videos from text, images, or other videos using CogVideo AI.")
    
    with gr.Tab("Generate"):
        with gr.Row():
            with gr.Column():
                prompt_input = gr.Textbox(
                    label="Prompt",
                    placeholder="Enter a description of the video you want to generate...",
                    lines=3
                )
                
                with gr.Row():
                    with gr.Column():
                        image_input = gr.Image(label="Image Input (Optional)", type="filepath")
                    
                    with gr.Column():
                        video_input = gr.Video(label="Video Input (Optional)")
                
                with gr.Row():
                    video_strength = gr.Slider(
                        minimum=0.0,
                        maximum=1.0,
                        value=0.7,
                        step=0.05,
                        label="Video Strength"
                    )
                
                with gr.Row():
                    steps = gr.Slider(
                        minimum=10,
                        maximum=100,
                        value=50,
                        step=1,
                        label="Inference Steps"
                    )
                    
                    guidance = gr.Slider(
                        minimum=1.0,
                        maximum=15.0,
                        value=7.5,
                        step=0.5,
                        label="Guidance Scale"
                    )
                
                seed_input = gr.Number(
                    label="Seed (-1 for random)",
                    value=-1,
                    precision=0
                )
                
                generate_btn = gr.Button("Generate Video", variant="primary")
            
            with gr.Column():
                output_video = gr.Video(label="Generated Video")
                output_info = gr.Textbox(label="Generation Info")
    
    # Connect the generate button to the generate_video function
    generate_btn.click(
        fn=generate_video,
        inputs=[
            prompt_input,
            image_input,
            video_input,
            video_strength,
            steps,
            guidance,
            seed_input
        ],
        outputs=[output_video, output_info]
    )
    
    # Add examples
    gr.Examples(
        examples=[
            ["A cat playing with a ball of yarn", None, None, 0.7, 50, 7.5, 42],
            ["A spaceship flying through a nebula", None, None, 0.7, 50, 7.5, 123],
        ],
        inputs=[
            prompt_input,
            image_input,
            video_input,
            video_strength,
            steps,
            guidance,
            seed_input
        ],
    )

# Launch the app
if __name__ == "__main__":
    demo.launch(share=True)
EOL

# Copy cogstudio.py to the gradio_composite_demo folder
echo "Copying cogstudio.py to the gradio_composite_demo folder..."
cp cogstudio.py CogVideo/inference/gradio_composite_demo/

# Navigate to the gradio_composite_demo folder
cd CogVideo/inference/gradio_composite_demo

# Create a virtual environment if it doesn't exist
if [ ! -d "env" ]; then
    echo "Creating Python virtual environment..."
    python -m venv env
else
    echo "Virtual environment already exists."
fi

# Activate the virtual environment
echo "Activating virtual environment..."
source env/bin/activate

# Install the CogVideo gradio dependencies
echo "Installing CogVideo gradio dependencies..."
pip install -r requirements.txt

# Install PyTorch for CUDA
echo "Installing PyTorch for CUDA..."
pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cu121

# Install the latest version of moviepy
echo "Installing the latest version of moviepy..."
pip install moviepy==2.0.0.dev2

# Create outputs directory
echo "Creating outputs directory..."
mkdir -p outputs

echo "Installation complete!"
echo "To start CogStudio, run the following commands:"
echo "cd $(pwd)"
echo "source env/bin/activate"
echo "python cogstudio.py"
