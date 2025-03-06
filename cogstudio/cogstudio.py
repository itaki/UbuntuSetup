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
import utils
from rife_model import load_rife_model, rife_inference_with_latents
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
    generator = torch.Generator(device=device).manual_seed(seed)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_path = os.path.join(output_dir, f"cogvideo_{timestamp}.mp4")
    
    progress(0, desc="Preparing...")
    
    try:
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
                generator=generator,
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
                generator=generator,
            ).videos
            
        else:
            # Text-to-video generation
            progress(0.1, desc="Generating video from text...")
            output = pipe(
                prompt=prompt,
                num_inference_steps=num_inference_steps,
                guidance_scale=guidance_scale,
                generator=generator,
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
