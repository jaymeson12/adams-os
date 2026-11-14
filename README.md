# Adams OS

## About
Adams OS is a personal backup of my UI customisations on openSUSE Tumbleweed with KDE Plasma.  It is a configuration layer (a set of visual customisations intended to be used on an already-installed openSUSE distribution); it is not a standalone distribution unto itself.

## Prerequisites

### Required
- An openSUSE Leap 16.x or Tumbleweed installation (refer to openSUSE official documentation and ISO files).
- git (`sudo zypper install git`)
- zsh (`sudo zypper install zsh`)

Note that Adams OS is a **user-level** script.  It will not install the above programs for you as using **sudo** is against the ethos and goals of Adams OS.

## Before Running

The script will automatically restart the machine after it has run.  Make sure to save all work and close any running applications BEFORE running the script.

## Usage
1. Clone the project: `git clone https://github.com/jaymeson12/adams-os.git`.
2. Make the install script executable (`chmod +x install.sh`).
3. Run the script at the user level **not with sudo** (`./install.sh`).
4. That's it.  **The script will reboot the machine automatically once complete.**

Note: The Plasma desktop customisations are based on a backup of my personal desktop system.  Results may vary and are completely at your risk.  If the desktop widgets, panels, etc. are in strange places, you might have to enter Edit Mode on Plasma and adjust the widgets and panels manually.

## Post Installation Instructions

Because KDE Plasma saves exact screen coordinates and hardware IDs in its layout files, your panels and desktop widgets may need a quick manual adjustment after a fresh install (especially in Virtual Machines).

If your top panel with quick launch is full-width and not auto hiding or the desktop widgets are missing:

1. Right-click an empty space on the desktop --> Enter Edit Mode --> Position the panel as intended by setting the width to "Fit Content" and in the top centre of the screen, with Visibility set to auto hide.
2. Adjust the panel height to 60.

If the bottom panel is floating and looks slightly off:

1. Right-click an empty space on the desktop --> Enter Edit Mode --> Disable panel floating.
2. Adjust the panel height to 34.

If the desktop widgets are not displaying, right-click an empty space on the desktop --> Enter Edit Mode --> Add Widgets and add the desktop widgets back (or add your preferred ones).

If the links under the "Computer" tab (like System Settings or Discover) in the Kickoff Classic menu are not functional, this is a known widget caching quirk of KDE Plasma.  To fix it instantly:

1. Right-click an empty space on the desktop --> Enter Edit Mode.
2. Click on the bottom panel.
3. Hover over the Kickoff Classic menu icon, and when prompted, remove the widget.
4. Go to "Add Widgets...", and add the Kickoff Classic menu back.

If this does not work, you can uninstall the widget from the "More Widgets..." menu, then reinstall it from the "Get New..." section by searching for Kickoff classic.

## Acknowledgements
Adams OS would not exist without the incredible work on the openSUSE project and community, the KDE community, among others.

- **Base System:** The configuration is **Built on openSUSE**.  I am immensely grateful to the openSUSE developers and contributors for creating such a stable, flexible, and powerful foundation.
- **Desktop Environment:** Thank you to the **KDE Community** for the endlessly customisable Plasma desktop.
- **Theme Integration:** The visual design is inspired by the classic Plasma 5 aesthetics and the Catppuccin colour palette (coming in a future update).

## Important Note
Adams OS is an independent project and is not affiliated with, endorsed by, or sponsored by the openSUSE Project, SUSE LLC, or the KDE Community.

Scripts were built with the assistance of AI (DeepSeek).  Use of the script is at your own risk.  Again, DeepSeek is the tool I used and Adams OS is not affiliated with, endorsed by, or sponsored by it.
