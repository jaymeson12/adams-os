#!/usr/bin/env bash
# Copyright (C) 2026 Jaymeson Adams
# SPDX-License-Identifier: MIT

# Adams OS is a post installation configuration overlay for openSUSE Leap and Tumbleweed.  It is a PERSONAL BACKUP of my UI customization.
# This project is **Built on openSUSE** (https://www.opensuse.org).
# It is not affiliated with or endorsed by the openSUSE project, nor is it affiliated with or endorsed by any project with a similar name.
# This script was built with the assistance of AI (DeepSeek).  Use of the script is at your own risk.

# Stop the script if any command fails
set -e

echo "Detecting operating system..."

# Check if /etc/os-release exists
if [ -f /etc/os-release ]; then
    # Source the file to load the variables (like $ID)
    . /etc/os-release
    DISTRO_ID="$ID"
else
    echo "X Error: Could not find /etc/os-release. Cannot determine OS."
    exit 1
fi

# Determine the custom OS name based on the distro ID
if [ "$DISTRO_ID" = "opensuse-tumbleweed" ]; then
    OS_NAME="Adams OS Rolling"
elif [ "$DISTRO_ID" = "opensuse-leap" ]; then
    OS_NAME="Adams OS Stable"
else
    echo "X Error: Unsupported distribution ($DISTRO_ID)."
    echo "This script only supports openSUSE Tumbleweed and openSUSE Leap."
    exit 1
fi

echo "V Detected supported OS: $OS_NAME"

echo "Configuring KDE Info Centre..."

# Create the config file with the dynamic OS name and your GitHub link
cat <<EOF > ~/.config/kcm-about-distrorc
[General]
Name=$OS_NAME
LogoPath=preferences-system-linux
Website=https://github.com/jaymeson12/adams-os.git
EOF

echo "Configuring Fastfetch..."

mkdir -p ~/.config/fastfetch

if [ "$DISTRO_ID" = "opensuse-tumbleweed" ]; then
    cp configs/fastfetch-tumbleweed.jsonc ~/.config/fastfetch/config.jsonc
    # Optional: Inject the Tumbleweed branding
    sed -i "s/PLACEHOLDER_OS_NAME/$OS_NAME/g" ~/.config/fastfetch/config.jsonc
elif [ "$DISTRO_ID" = "opensuse-leap" ]; then
    cp configs/fastfetch-leap.jsonc ~/.config/fastfetch/config.jsonc
    # Optional: Inject the Leap branding
    sed -i "s/PLACEHOLDER_OS_NAME/$OS_NAME/g" ~/.config/fastfetch/config.jsonc
fi
