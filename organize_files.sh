#!/bin/bash

# Create directories if they don't exist
mkdir -p system_config
mkdir -p ml_setup
mkdir -p assets

# Move files to appropriate directories
mv conky.conf system_config/
mv setup_ml_environment.sh ml_setup/
mv accelerate_config.yaml ml_setup/
mv mountain.png assets/
mv cuda-keyring_1.1-1_all.deb ml_setup/
mv get-pip.py ml_setup/

# Clean up any empty directories
find . -type d -empty -delete

echo "Files have been organized into their appropriate directories." 