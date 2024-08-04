#!/bin/bash

# Ensure you have necessary permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Define paths
REPO_PATH="$(pwd)"
IMAGE_PATH="$REPO_PATH/logo.png"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/spinner"
PLYMOUTH_IMAGE_PATH="$PLYMOUTH_THEME_DIR/logo.png"

# Check if the image exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: $IMAGE_PATH not found!"
    exit 1
fi

# Ensure the Plymouth theme directory exists
if [ ! -d "$PLYMOUTH_THEME_DIR" ]; then
    echo "Error: Plymouth theme directory $PLYMOUTH_THEME_DIR not found!"
    exit 1
fi

# Copy the new splash screen image to the plymouth directory
cp $IMAGE_PATH $PLYMOUTH_IMAGE_PATH

# Update the plymouth configuration to use the spinner theme
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/spinner/spinner.plymouth 100
update-alternatives --set default.plymouth /usr/share/plymouth/themes/spinner/spinner.plymouth
update-initramfs -u

# Update the desktop background using dconf
DBUS_SESSION_BUS_ADDRESS=$(dbus-launch)
export DBUS_SESSION_BUS_ADDRESS
dconf write /org/mate/desktop/background/picture-filename "'$IMAGE_PATH'"

echo "Splash screens and desktop background have been updated. Please reboot the system."
