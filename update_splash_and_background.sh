#!/bin/bash

# Ensure you have necessary permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Define paths
REPO_PATH="$(pwd)"
IMAGE_PATH="$REPO_PATH/logo.png"
PLYMOUTH_IMAGE_PATH="/usr/share/plymouth/themes/default/logo.png"

# Check if the image exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: $IMAGE_PATH not found!"
    exit 1
fi

# Copy the new splash screen image to plymouth directory
cp $IMAGE_PATH $PLYMOUTH_IMAGE_PATH

# Update the plymouth configuration to use the new image
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/default/default.plymouth 100
update-initramfs -u

# Update the desktop background using dconf
dconf write /org/mate/desktop/background/picture-filename "'$IMAGE_PATH'"

echo "Splash screens and desktop background have been updated. Please reboot the system."
