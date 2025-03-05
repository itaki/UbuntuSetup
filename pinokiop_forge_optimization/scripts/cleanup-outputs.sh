#!/bin/bash
#########################################################
# Pinokio Forge Output Cleanup Script
# This script deletes all files and empty directories in the outputs directory
# to free up disk space while preserving the main directory structure.
#########################################################

# Set variables
FORGE_OUTPUTS_DIR="$HOME/pinokio/api/stable-diffusion-webui-forge.git/app/outputs"
LOG_FILE="$HOME/pinokio/cleanup_log.txt"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log messages
log_message() {
    echo "[$DATE] $1" >> "$LOG_FILE"
    echo "[$DATE] $1"
}

# Check if outputs directory exists
if [ ! -d "$FORGE_OUTPUTS_DIR" ]; then
    log_message "ERROR: Outputs directory not found at $FORGE_OUTPUTS_DIR"
    exit 1
fi

# Log start of cleanup
log_message "Starting cleanup of Pinokio Forge outputs directory"

# Get initial disk usage
INITIAL_USAGE=$(du -sh "$FORGE_OUTPUTS_DIR" 2>/dev/null | cut -f1)
log_message "Initial disk usage: $INITIAL_USAGE"

# Count files before deletion
FILE_COUNT=$(find "$FORGE_OUTPUTS_DIR" -type f | wc -l)
log_message "Found $FILE_COUNT files to delete"

# Count directories before deletion
DIR_COUNT=$(find "$FORGE_OUTPUTS_DIR" -mindepth 1 -type d | wc -l)
log_message "Found $DIR_COUNT directories to process"

# Delete all files
find "$FORGE_OUTPUTS_DIR" -type f -delete

# Delete empty directories but preserve the main structure
# This will keep txt2img-images, img2img-images, etc. but remove dated folders inside them
find "$FORGE_OUTPUTS_DIR" -mindepth 2 -type d -empty -delete

# Verify file deletion
REMAINING_FILES=$(find "$FORGE_OUTPUTS_DIR" -type f | wc -l)
if [ "$REMAINING_FILES" -eq 0 ]; then
    log_message "Successfully deleted all files"
else
    log_message "WARNING: $REMAINING_FILES files could not be deleted"
fi

# Count remaining directories
REMAINING_DIRS=$(find "$FORGE_OUTPUTS_DIR" -mindepth 2 -type d | wc -l)
log_message "Removed $(($DIR_COUNT - $REMAINING_DIRS)) empty directories"

# Get final disk usage
FINAL_USAGE=$(du -sh "$FORGE_OUTPUTS_DIR" 2>/dev/null | cut -f1)
log_message "Final disk usage: $FINAL_USAGE"

# Log completion
log_message "Cleanup completed successfully"
log_message "----------------------------------------" 