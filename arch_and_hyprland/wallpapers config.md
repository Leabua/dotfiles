# Wallpapers Configuration

## Overview
This directory contains wallpaper images used by the hyprpaper daemon for desktop background display.

## Directory Structure
- `~/Wallpapers/`: Directory containing wallpaper images (symlinked from ~/.dotfiles/wallpapers/Wallpapers via stow)

## Setup Commands
No special setup commands are required for wallpapers beyond ensuring the directory exists and contains image files.

## Why This Configuration
- Wallpapers are stored in a dedicated directory for organization
- The wallpaper rotation script (`~/scripts/rotate_wallpaper.sh`) automatically uses images from this directory
- Supported formats: jpg, jpeg, png, gif
- Current collection includes various landscape and abstract images for variety
- The hyprpaper daemon is configured to display these wallpapers with cover fit mode
- The wallpaper rotation script ensures consistency between hyprpaper (desktop) and hyprlock (lock screen)

## Installed Packages
No specific packages required for the wallpapers themselves, but hyprpaper is needed to display them. See the native packages list for the exact version.

## Usage
- Wallpapers are automatically rotated via the rotate_wallpaper.sh script (typically bound to a key combination)
- To manually add wallpapers, copy image files to `~/Wallpapers/`
- The wallpaper rotation script will automatically detect new additions
- For best results, use images that match your screen resolution or have similar aspect ratios