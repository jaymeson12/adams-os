# Adams OS

## About
Adams OS is a personal backup of my UI customisations on openSUSE Tumbleweed with KDE Plasma.  It is a configuration layer (a set of visual customisations intended to be used on an already-installed openSUSE distribution); it is not a standalone distribution unto itself.

## Prerequisites

### Required
- An openSUSE Leap 16.x or Tumbleweed installation (refer to openSUSE official documentation and ISO files).
- git (sudo zypper install git)
- zsh (sudo zypper install zsh)

Note that Adams OS is a **user-level** script.  It will not install the above programs for you as using **sudo** is against the ethos and goals of Adams OS.

## Before Running

The script will automatically restart the machine after it has run.  Make sure to save all work and close any running applications BEFORE running the script.

## Usage
1. Clone the project: `git clone https://github.com/jaymeson12/adams-os.git`.
2. Make the install script executable (`chmod +x install.sh`).
3. Run the script at the user level **not with sudo** (`./install.sh`).
4. That's it.  **The script will reboot the machine automatically once complete.**

Note: The Plasma desktop customisations are based on a backup of my personal desktop system.  Results may vary and are completely at your risk.  If the desktop widgets, panels, etc. are in strange places, you might have to enter Edit Mode on Plasma and adjust the widgets and panels manually.

## Acknowledgements
Adams OS would not exist without the incredible work on the openSUSE project and community, the KDE community, among others.

- **Base System:** The configuration is **Built on openSUSE**.  I am immensely grateful to the openSUSE developers and contributors for creating such a stable, flexible, and powerful foundation.
- **Desktop Environment:** Thank you to the **KDE Community** for the endlessly customisable Plasma desktop.
- **Theme Integration:** The visual design is inspired by the classic Plasma 5 aesthetics and the Catppuccin colour palette (coming in a future update).

## Important Note
Adams OS is an independent project and is not affiliated with, endorsed by, or sponsored by the openSUSE Project, SUSE LLC, or the KDE Community.

Scripts were built with the assistance of AI (DeepSeek).  Use of the script is at your own risk.
