#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run this script with sudo"
    exit 1
fi

# Create destination directory if it doesn't exist
mkdir -p /etc/opensnitchd/rules/

# Copy all allow and deny rules
echo "Copying OpenSnitch rules to /etc/opensnitchd/rules/"
cp "$(dirname "$0")"/[ad][el][nl][yo][w-]*.json /etc/opensnitchd/rules/

echo "Rules copied successfully!" 