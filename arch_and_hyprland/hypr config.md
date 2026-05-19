# Hyprland Configuration

## Overview
Hyprland is a dynamic tiling Wayland compositor that is highly configurable and themeable. It is configured via a Lua script that sources multiple module files.

## Configuration Files
- `~/.config/hypr/hyprland.lua`: Main entry point that defines variables and sources modules.
- `~/.config/hypr/hypridle.conf`: Configuration for hypridle (idle timeout actions).
- `~/.config/hypr/hyprlock.conf`: Configuration for hyprlock (screen locker).
- `~/.config/hypr/hyprpaper.conf`: Configuration for hyprpaper (wallpaper manager).
- `~/.config/hypr/hyprsunset.conf`: Configuration for hyprsunset (color temperature adjustment).
- `~/.config/hypr/modules/`: Directory containing Lua modules for autostart, bindings, inputs, looknfeel, monitors, tiling, utilities, and windowrules.

## Setup Commands
No special setup commands are required for Hyprland beyond ensuring the package is installed and the configuration is placed in `~/.config/hypr/`.

## Why This Configuration
- The configuration uses a Lua script (`hyprland.lua`) to allow for programmable and modular configuration.
- Environment variables are set for cursor size and theme (Bibata-Modern-Ice).
- The configuration sources modules that separate concerns:
  - `autostart`: Applications to start on login.
  - `bindings`: Keybindings and mouse bindings.
  - `inputs`: Input device configuration.
  - `looknfeel`: Appearance, theme, and decoration settings.
  - `monitors`: Monitor configuration and layout.
  - `tiling`: Tiling layout and behavior.
  - `utilities`: Utility functions and scripts.
  - `windowrules`: Rules for specific applications (e.g., floating, size, position).
- This modular approach makes the configuration easier to maintain and understand.

## Installed Packages
Hyprland and related utilities (hypridle, hyprlock, hyprpaper, hyprsunset) are required. See the native packages list for the exact version.