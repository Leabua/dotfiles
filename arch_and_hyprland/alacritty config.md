# Alacritty Configuration

## Overview
Alacritty is a GPU-accelerated terminal emulator. It is configured via TOML and is set up to use a dynamic theme from the Omarchy theme system.

## Configuration Files
- `~/.config/alacritty/alacritty.toml`: Main configuration file that imports the current theme and sets basic options.

## Setup Commands
No special setup commands are required for Alacritty beyond ensuring the package is installed.

## Why This Configuration
- The configuration uses `general.import` to dynamically load the theme from Omarchy, allowing for easy theme switching.
- Font is set to JetBrainsMono Nerd Font at size 14 for readability and icon support.
- Window decorations are set to "None" for a clean look, with padding adjusted for comfort.
- Opacity is set to 0.9 for slight transparency.
- Keyboard bindings are customized for copy-paste using Shift+Insert and Ctrl+Insert.

## Installed Packages
Alacritty package is required. See the native packages list for the exact version.