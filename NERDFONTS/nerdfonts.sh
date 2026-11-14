#!/usr/bin/sh

echo "Installing nerd fonts..."

git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git ~/nerd-fonts # Clones nerd fonts to the home folder
cp -r ~/nerd-fonts/patched-fonts/* ~/.local/share/fonts/ # Copies nerd fonts to the user's font folder
cp -r ~/nerd-fonts/LICENSE ~/.local/share/fonts/ # Copies nerd font licence to the user's font folder

# Update font cache
fc-cache -vf

# Remove nerd font git clone
rm -rf ~/nerd-fonts
