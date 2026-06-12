# Scripts Configuration

## Overview
This directory contains custom scripts that enhance the functionality of the Hyprland desktop environment. These scripts are designed to be called from keybindings or executed manually.

## Configuration Files
- `~/scripts/cliphist-rofi`: Script for managing clipboard history with rofi interface
- `~/scripts/rotate_wallpaper.sh`: Script for rotating wallpapers and updating hyprpaper/hyprlock configurations

## Setup Commands
Special setup is required for scripts to be executable and accessible:
```bash
# Make scripts executable
chmod +x ~/.local/bin/*
```

## Why This Configuration
- The scripts provide essential functionality that integrates tightly with the Hyprland ecosystem:

### cliphist-rofi
This script provides a graphical interface for managing clipboard history using rofi:
- **Dependencies**: Requires `cliphist`, `rofi`, `wl-copy`, and `notify-send`
- **Functionality**:
  - Lists clipboard history items using cliphist
  - Detects binary data (images) and generates thumbnails for preview
  - Uses a custom rofi theme for consistent appearance
  - Allows selection via rofi interface
  - Copies selected item to clipboard using wl-copy
  - Shows notifications for empty history or errors
- **Setup**: The script references a custom rofi theme at `$HOME/.dotfiles/rofi/rofi/clipboard.rasi` and creates a thumbnail cache at `$HOME/.cache/cliphist_thumbs`

### rotate_wallpaper.sh
This script automates wallpaper rotation while maintaining consistency between hyprpaper (wallpaper daemon) and hyprlock (screen locker):
- **Dependencies**: Requires `hyprctl`, `notify-send`, and standard bash utilities
- **Functionality**:
  - Scans `$HOME/Wallpapers` for image files (jpg, jpeg, png, gif)
  - Identifies current wallpaper from hyprpaper config
  - Calculates next wallpaper in rotation
  - Uses hyprctl IPC to:
    1. Preload the new wallpaper
    2. Set it as the current wallpaper for all monitors
    3. Unload the old wallpaper to free memory
  - Updates hyprlock configuration to use the same wallpaper for lock screen
  - Persists changes to hyprpaper config file for survival across reboots
  - Shows notification with new wallpaper name and preview
- **Setup**: Requires a `~/Wallpapers` directory with image files

## Usage
- **cliphist-rofi**: Bind to a key combination in Hyprland (e.g., Super+V) to access clipboard history
- **rotate_wallpaper.sh**: Bind to a key combination in Hyprland (e.g., Super+W) to rotate wallpapers, or run manually

## Notes
Both scripts should be placed in `~/.local/bin/` or another directory in your PATH and made executable for easy access.