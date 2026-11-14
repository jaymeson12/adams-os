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
    OS_NAME="Adams OS"
    OS_CHANNEL="Rolling"
    OS_VERSION="26.11" # Update as new versions get released
elif [ "$DISTRO_ID" = "opensuse-leap" ]; then
    OS_NAME="Adams OS"
    OS_CHANNEL="Stable"
    OS_VERSION="26.11"
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
Version=$OS_VERSION
Variant=$OS_CHANNEL
LogoPath=preferences-system-linux
Website=https://github.com/jaymeson12/adams-os.git
EOF

echo "Configuring Fastfetch..."

mkdir -p ~/.config/fastfetch

if [ "$DISTRO_ID" = "opensuse-tumbleweed" ]; then
    cp fastfetch/fastfetch-tumbleweed.jsonc ~/.config/fastfetch/config.jsonc
    # Optional: Inject the Tumbleweed branding
    sed -i "s/PLACEHOLDER_OS_NAME/$OS_NAME $OS_CHANNEL/g" ~/.config/fastfetch/config.jsonc
elif [ "$DISTRO_ID" = "opensuse-leap" ]; then
    cp fastfetch/fastfetch-leap.jsonc ~/.config/fastfetch/config.jsonc
    # Optional: Inject the Leap branding
    sed -i "s/PLACEHOLDER_OS_NAME/$OS_NAME $OS_CHANNEL/g" ~/.config/fastfetch/config.jsonc
fi

# ----- Applying Breeze Classic -----
echo "Applying Breeze Classic colour scheme..."
plasma-apply-lookandfeel --apply org.kde.breeze.desktop
plasma-apply-colorscheme BreezeClassic

# ----- Install nerd fonts -----
NERDFONTS/nerdfonts.sh

# ----- Install widgets -----
echo "Installing quickclock and Kickoff Classic"
mkdir -p ~/.local/share/plasma/plasmoids/
cp -r ASSETS/io.github.kevinbudz.quickclock ~/.local/share/plasma/plasmoids/
cp -r ASSETS/org.kde.plasma.kickoffclassic ~/.local/share/plasma/plasmoids/

# ----- Setting zsh as default shell IF INSTALLED ON THE SYSTEM -----
if command -v zsh >/dev/null 2>&1; then
    SHELL_CMD="Command=/usr/bin/zsh"
else
    SHELL_CMD=""
fi

cat <<EOF > ~/.local/share/konsole/AdamsOS.profile
[General]
Name=Adams OS
Parent=FALLBACK/
$SHELL_CMD

[Appearance]
Font=DejaVuSansM Nerd Font Mono,10
EOF
kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile "AdamsOS.profile"
# Hide the main toolbar
kwriteconfig6 --file konsolerc --group MainWindow --key ShowToolbar false
# Hide the Session Toolbar (the tabs bar, etc.)
kwriteconfig6 --file konsolerc --group MainWindow --key ShowSessionToolbar false
# Show the menu bar
kwriteconfig6 --file konsolerc --group MainWindow --key ShowMenuBar true

# ----- Wallpaper setting (Elarun) -----
echo "Setting Elarun wallpaper, the last default from KDE 4, and copying over good old Plasma 5 wallpapers ..."
mkdir -p ~/.local/share/wallpapers
cp Wallpaper/* ~/.local/share/wallpapers
plasma-apply-wallpaperimage ~/.local/share/wallpapers/Elarun.png

# ----- Configuring virtual desktops -----
kwriteconfig6 --file kwinrc --group Desktops --key Number 4

# ----- Enabling Breeze titlebar gradient -----
kwriteconfig6 --file kwinrc --group org.kde.breeze.decoration --key DrawBackgroundGradient true

# ----- Enable my custom desktop layout -----
echo "Enable / restore ADAMS OS layout ..."
cp ASSETS/plasma-org.kde.plasma.desktop-appletsrc ~/.config/

# ----- Refresh Plasma -----
echo "Refreshing the Plasma desktop ..."
kquitapp6 plasmashell && kstart plasmashell &
echo "Adams OS setup complete.  Please log out and back in for all changes to take effect."
