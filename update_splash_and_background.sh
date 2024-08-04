#!/bin/bash

# Ensure you have necessary permissions
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Define paths
REPO_PATH="$(pwd)"
IMAGE_PATH="$REPO_PATH/logo.png"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/ubuntu-mate-logo"
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
echo "Copying splash screen image to Plymouth directory..."
cp $IMAGE_PATH $PLYMOUTH_IMAGE_PATH

# Update the plymouth configuration to use the ubuntu-mate-logo theme
echo "Updating Plymouth configuration..."
update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/ubuntu-mate-logo/ubuntu-mate-logo.plymouth 100
update-alternatives --set default.plymouth /usr/share/plymouth/themes/ubuntu-mate-logo/ubuntu-mate-logo.plymouth
update-initramfs -u

# Update the desktop background using dconf
echo "Updating desktop background settings..."
eval $(dbus-launch --sh-syntax)
dconf write /org/mate/desktop/background/picture-filename "'$IMAGE_PATH'"
dconf write /org/mate/desktop/background/picture-options "'zoom'"
dconf write /org/mate/desktop/background/primary-color "'#000000'"

echo "Verifying dconf settings..."
dconf read /org/mate/desktop/background/picture-filename
dconf read /org/mate/desktop/background/picture-options
dconf read /org/mate/desktop/background/primary-color

# Attempt to restart mate-settings-daemon to apply changes
echo "Restarting mate-settings-daemon..."
killall mate-settings-daemon

# Restart MATE components
echo "Restarting MATE components..."
mate-panel --replace &
marco --replace &

# Check if mate-settings-daemon restarted successfully
if [ $? -ne 0 ]; then
    echo "mate-settings-daemon failed to restart. Please log out and log back in to apply changes."
fi

echo "Splash screens and desktop background have been updated. Please reboot the system."
