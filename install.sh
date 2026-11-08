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
Website=
EOF

echo "Configuring Fastfetch..."

# Ensure the fastfetch config directory exists
mkdir -p ~/.config/fastfetch

# Create the config file with the dynamic OS name
cat <<EOF > ~/.config/fastfetch/config.jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
  "logo": {
    "type": "auto",
    "source": "Linux",
    "width": null,
    "height": null,
    "padding": {
      "top": 0,
      "left": 0,
      "right": 4
    },
    "printRemaining": true,
    "preserveAspectRatio": false,
    "cache": "regen",
    "position": "left",
    "chafa": {
      "fgOnly": false,
      "symbols": "block+border+space-wide-inverted"
    }
  },
  "display": {
    "stat": false,
    "pipe": false,
    "showErrors": false,
    "disableLinewrap": true,
    "hideCursor": false,
    "separator": " 󰁔 ",
    "color": {
      "keys": "38;2;166;209;137",
      "title": "",
      "output": "38;2;198;208;245",
      "separator": "38;2;166;209;137"
    },
    "brightColor": true,
    "duration": {
      "abbreviation": false,
      "spaceBeforeUnit": "default"
    },
    "size": {
      "maxPrefix": "YB",
      "binaryPrefix": "iec",
      "ndigits": 2,
      "spaceBeforeUnit": "default"
    },
    "temp": {
      "unit": "D",
      "ndigits": 1,
      "color": {
        "green": "32",
        "yellow": "93",
        "red": "91"
      },
      "spaceBeforeUnit": "default"
    },
    "percent": {
      "type": [
        "num",
        "num-color"
      ],
      "ndigits": 0,
      "color": {
        "green": "32",
        "yellow": "93",
        "red": "91"
      },
      "spaceBeforeUnit": "default",
      "width": 0
    },
    "bar": {
      "char": {
        "elapsed": "■",
        "total": "-"
      },
      "border": {
        "left": "[ ",
        "right": " ]",
        "leftElapsed": "",
        "rightElapsed": ""
      },
      "color": {
        "elapsed": "auto",
        "total": "97",
        "border": "97"
      },
      "width": 10
    },
    "fraction": {
      "ndigits": 2
    },
    "noBuffer": false,
    "key": {
      "width": 0,
      "type": "icon",
      "paddingLeft": 0
    },
    "freq": {
      "ndigits": 2,
      "spaceBeforeUnit": "default"
    },
    "constants": []
  },
  "general": {
    "thread": true,
    "processingTimeout": 5000,
    "detectVersion": true,
    "playerName": "",
    "dsForceDrm": false
  },
  "modules": [
    {
      "type": "title",
      "key": " ",
      "keyIcon": "",
      "fqdn": false,
      "color": {
        "user": "4;38;2;166;209;137",
        "at": "4;38;2;166;209;137",
        "host": "4;38;2;166;209;137"
      }
    },
    "break",
    {
      "type": "os",
      "keyIcon": "",
      "format": "$OS_NAME {arch}"
    },
    {
      "type": "kernel",
      "keyIcon": ""
    },
       {
      "type": "command",
      "keyIcon": "",
      "text": "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days",
    },
    {
      "type": "uptime",
      "keyIcon": ""
    },
    "break",
    {
      "type": "packages",
      "keyIcon": "󰏖",
      "disabled": [
        "winget"
      ],
      "combined": false
    },
    {
      "type": "shell",
      "keyIcon": ""
    },
    {
      "type": "de",
      "keyIcon": "",
      "slowVersionDetection": false
    },
    {
      "type": "terminal",
      "keyIcon": ""
    },
    "break",
    {
      "type": "cpu",
      "keyIcon": "",
      "temp": false,
      "showPeCoreCount": false
    },
    {
      "type": "gpu",
      "keyIcon": "󰾲",
      "driverSpecific": false,
      "detectionMethod": "pci",
      "temp": false,
      "hideType": "none",
      "percent": {
        "green": 50,
        "yellow": 80,
        "type": 0
      }
    },
    {
      "type": "memory",
      "keyIcon": "",
      "percent": {
        "green": 50,
        "yellow": 80,
        "type": 0
      }
    },
    {
      "type": "swap",
      "percent": {
        "green": 50,
        "yellow": 80,
        "type": 0
      },
      "keyIcon": "󰓡",
      "separate": false
    },
    {
      "type": "disk",
      "keyIcon": "",
      "showRegular": true,
      "showExternal": true,
      "showHidden": false,
      "showSubvolumes": false,
      "showReadOnly": true,
      "showUnknown": false,
      "folders": "",
      "hideFolders": "/efi:/boot:/boot/*",
      "hideFS": "",
      "useAvailable": false,
      "percent": {
        "green": 50,
        "yellow": 80,
        "type": 0
      }
    },
    "break",
    {
      "type": "colors",
      "key": " ",
      "keyIcon": "",
      "symbol": "circle",
      "paddingLeft": 0,
      "block": {
        "width": 3,
        "range": [
          0,
          15
        ]
      }
    }
  ]
}
EOF
