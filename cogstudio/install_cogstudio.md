# CogStudio Installation Guide

This document explains the installation process for CogStudio, a tool for AI video generation based on the CogVideo repository.

## Installation Steps

The `install_cogstudio.sh` script automates the installation of CogStudio on Ubuntu by following these steps:

1. Clone the CogVideo repository:
   ```bash
   git clone https://github.com/THUDM/CogVideo
   ```

2. Automatically create and copy the cogstudio.py file to the CogVideo/inference/gradio_composite_demo folder.
   (The script generates a custom cogstudio.py file based on the CogVideo repository structure)

3. Create a Python virtual environment:
   ```bash
   cd CogVideo/inference/gradio_composite_demo
   python -m venv env
   ```

4. Activate the virtual environment:
   ```bash
   source env/bin/activate
   ```

5. Install the CogVideo gradio dependencies:
   ```bash
   pip install -r requirements.txt
   ```

6. Install PyTorch for CUDA:
   ```bash
   pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cu121
   ```

7. Install the latest version of moviepy:
   ```bash
   pip install moviepy==2.0.0.dev2
   ```

8. Start the application:
   ```bash
   python cogstudio.py
   ```

## Important Notes

### The `cogstudio.py` File

The `cogstudio.py` file is not included in the CogVideo repository by default. Our installation script automatically creates this file with a custom implementation based on the CogVideo repository structure. This file provides a user-friendly interface for generating videos using the CogVideo model.

Our implementation includes:
- Text-to-video generation
- Image-to-video generation
- Video-to-video generation
- Adjustable parameters for video generation (steps, guidance scale, etc.)
- Random seed generation for reproducibility
- Demo mode for systems with limited GPU memory

### Demo Mode

If your system doesn't have enough GPU memory to load the full models (at least 24GB of VRAM is recommended), CogStudio will automatically fall back to a demo mode. In this mode, it will create simple placeholder videos to demonstrate the interface without actually running the AI models.

To use the full functionality of CogStudio, you'll need a system with sufficient GPU memory. The models require approximately:
- 20-24GB of VRAM for the base model
- Additional memory for processing larger videos or images

### System Requirements

- CUDA-compatible GPU (recommended)
- Python 3.8 or higher
- Sufficient disk space for the models (several GB)
- At least 24GB of GPU memory for full functionality

### Running CogStudio

After installation, you can run CogStudio with:

```bash
cd ~/UbuntuSetup/cogstudio/CogVideo/inference/gradio_composite_demo
source env/bin/activate
python cogstudio.py
```

This will start the Gradio web interface, which you can access through your web browser at http://localhost:7860.

### Troubleshooting

If you encounter any issues during installation or running CogStudio, here are some common solutions:

1. **CUDA errors**: Make sure you have the correct CUDA version installed and that your GPU is compatible.
2. **Memory errors**: If you see "CUDA out of memory" errors, your GPU doesn't have enough memory to run the full models. CogStudio will automatically fall back to demo mode.
3. **Missing dependencies**: If you encounter missing dependencies, try installing them manually with pip.
4. **Permission issues**: Make sure you have the necessary permissions to write to the installation directory.

### Customization

You can customize the CogStudio interface by modifying the cogstudio.py file. Some possible customizations include:
- Adding more tabs for different generation modes
- Changing the default parameters
- Adding more examples
- Implementing additional post-processing options
- Adjusting the model size or precision to fit your GPU memory 