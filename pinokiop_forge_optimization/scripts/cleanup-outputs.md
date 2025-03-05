# Pinokio Forge Output Cleanup

## Overview

This document explains the automated cleanup script for Pinokio Forge's output directories. The script is designed to run daily at 1 AM to remove generated images and empty date-based directories, freeing up disk space while preserving the main directory structure.

## Why This Script Is Needed

Stable Diffusion WebUI Forge generates a large number of images during normal use, organized in dated folders. These images and folders can quickly consume disk space, especially when generating high-resolution images or running batch operations. Regular cleanup helps maintain system performance and prevents disk space issues.

## Implementation Details

The script performs the following operations:

1. Checks if the outputs directory exists
2. Logs the initial disk usage
3. Counts the number of files and directories to be processed
4. Deletes all files in the outputs directory
5. Removes empty directories while preserving the main structure (txt2img-images, img2img-images, etc.)
6. Verifies that all files were deleted successfully
7. Reports how many directories were removed
8. Logs the final disk usage
9. Records all operations in a log file

## Cron Job Configuration

The script is scheduled to run daily at 1 AM using cron:

```
0 1 * * * /home/mm/UbuntuSetup/pinokiop_forge_optimization/scripts/cleanup-outputs.sh
```

## Log File

All cleanup operations are logged to:
```
/home/mm/pinokio/cleanup_log.txt
```

The log includes:
- Timestamp of each operation
- Initial disk usage
- Number of files deleted
- Number of directories removed
- Final disk usage
- Any errors or warnings encountered

## Customization

If you need to modify the script behavior:

1. **Change cleanup frequency**: Edit the cron job timing
2. **Preserve specific files**: Modify the `find` command to exclude certain patterns
3. **Change log location**: Update the `LOG_FILE` variable
4. **Keep certain dated folders**: Adjust the directory deletion depth with the `-mindepth` parameter

## Troubleshooting

If the script fails to run:

1. Check if the script has execute permissions
2. Verify that the outputs directory path is correct
3. Ensure the user running the cron job has permission to access the directories
4. Check the log file for specific error messages

## What Didn't Work

During development, we encountered and resolved these issues:

1. Using `rm -rf` directly was too aggressive and could potentially delete the main directory structure
2. Simple wildcards like `rm *` didn't work for nested directories
3. Initial attempts to log disk space savings had formatting issues with different `du` versions
4. Initially, we only deleted files but left empty dated folders, which cluttered the directory 