#!/bin/bash

# Define paths
REPO_PATH="$(pwd)"
IMAGE_PATH="$REPO_PATH/logo.png"

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
