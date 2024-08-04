#!/bin/bash

# Define paths
REPO_PATH="$(pwd)"
IMAGE_PATH="$REPO_PATH/logo.png"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/ubuntu-mate-logo"
PLYMOUTH_IMAGE_PATH="$PLYMOUTH_THEME_DIR/logo.png"

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

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

# Copy the new splash screen image to the Plymouth directory
echo "Copying splash screen image to Plymouth directory..."
cp $IMAGE_PATH $PLYMOUTH_IMAGE_PATH

# Update the Plymouth configuration to use the ubuntu-mate-logo theme
echo "Updating Plymouth configuration..."
update-initramfs -u

# Update the desktop background using dconf as the regular user
sudo -u $SUDO_USER bash <<EOF
eval \$(dbus-launch --sh-syntax)
dconf write /org/mate/desktop/background/picture-filename "'$IMAGE_PATH'"
dconf write /org/mate/desktop/background/picture-options "'zoom'"
dconf write /org/mate/desktop/background/primary-color "'#000000'"
killall mate-settings-daemon
mate-settings-daemon &
EOF

echo "Splash screens and desktop background have been updated. Please reboot the system."
