# !Command Center

This is the central hub for configuring the Arch and Hyprland system.

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation Steps](#installation-steps)
4. [Using GNU Stow](#using-gnu-stow)
5. [Package Installation](#package-installation)
6. [Configurations](#configurations)
7. [Post-Installation Steps](#post-installation-steps)

## Overview
This document guides you through setting up an Arch Linux system with Hyprland window manager and customized configurations for various applications.

## Prerequisites
- Arch Linux installed (base system)
- Internet connection
- Basic familiarity with the terminal

## Installation Steps
1. Install base system (follow Arch Linux installation guide)
2. Create a non-root user with sudo privileges
3. Install git: `sudo pacman -S git`
4. Clone this dotfiles repository: `git clone <repository-url> ~/.dotfiles`
5. Install GNU Stow: `sudo pacman -S stow`

## Using GNU Stow
This system uses GNU Stow to manage dotfiles. Stow creates symlinks from the repository to your home directory.

To install all configurations:
```bash
cd ~/.dotfiles
stow */
```

To install individual configurations:
```bash
cd ~/.dotfiles
stow <directory-name>
```

## Package Installation
First, install the native packages:
```bash
sudo pacman -S $(cat native_packages.txt)
```

Then install foreign/AUR packages (using yay or another AUR helper):
```bash
yay -S $(cat foreign_packages.txt)
```

## Configurations
- [[alacritty config]]
- [[bluetui config]]
- [[btop config]]
- [[fastfetch config]]
- [[ghostty config]]
- [[hypr config]]
- [[impala config]]
- [[mako config]]
- [[nvim config]]
- [[pacseek config]]
- [[rofi config]]
- [[satty config]]
- [[scripts config]]
- [[tmux config]]
- [[walker config]]
- [[wallpapers config]]
- [[waybar config]]
- [[wiremix config]]
- [[yazi config]]
- [[zsh config]]

## Post-Installation Steps
1. After installing packages and stowing dotfiles, log out and log back in (or restart)
2. Select Hyprland from your display manager menu
3. Some applications may require additional configuration:
   - Set your preferred browser, file manager, and terminal in `~/.config/hypr/hyprland.lua`
   - Wallpapers: Add images to `~/.config/hypr/wallpapers/`
   - Scripts: Make scripts executable with `chmod +x ~/.local/bin/*`

## Troubleshooting
- If a package fails to install, try installing it individually
- Check logs with `journalctl` for Hyprland or application-specific issues
- Ensure your graphics drivers are properly installed

## Maintenance
- To update configurations, pull changes from the repository and restow:
  ```bash
  cd ~/.dotfiles
  git pull
  stow */
  ```
- Update packages regularly:
  ```bash
  sudo pacman -Syu
  yay -Syu  # for AUR packages
  ```
