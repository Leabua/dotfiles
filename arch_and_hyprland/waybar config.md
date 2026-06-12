# Waybar Configuration

## Overview
Waybar is a highly customizable status bar for Wayland compositors, especially designed for Hyprland. It provides system information, application shortcuts, and more in a sleek, configurable bar.

## Configuration Files
- `~/.config/waybar/config.jsonc`: Main configuration file in JSONC format (JSON with comments).
- `~/.config/waybar/style.css`: CSS file for styling the bar.
- `~/.config/waybar/mocha.css`: Catppuccin Mocha theme for Waybar.
- `~/.config/waybar/scripts/`: Directory containing custom scripts for modules.

## Setup Commands
No special setup commands are required for waybar beyond ensuring the package is installed.

## Why This Configuration
- Waybar is chosen for its flexibility, performance, and integration with Hyprland.
- The configuration is designed for a clean, informative top bar:
  - **General Settings**:
    - `reload_style_on_change = true`: Automatically reloads style when config files change
    - `layer = "top"`: Places bar on top layer
    - `position = "top"`: Bar at top of screen
    - `spacing = 0`: No spacing between modules
  - **Module Layout**:
    - **Left**: Custom Arch logo, clock, media controls
    - **Center**: Hyprland workspaces (numbers 1-0)
    - **Right**: Pulseaudio (volume), network, battery
  - **Module Details**:
    - **Custom/Arch**: Shows Arch Linux logo () with JetBrainsMono font, clicks open sysmenu script
    - **Clock**: Shows time in HH:MM format, right-click opens timezone selector, left-click shows full date
    - **Custom/Media**: Executes media.sh script, shows JSON output, controls:
      - Left click: play/pause
      - Right click: next track
      - Scroll up/down: volume +/- 5%
    - **Hyplland/Workspaces**: Shows workspace numbers, clicking activates workspace, persistent workspaces 1-4
    - **Group/Tray-Expander**: Holds system tray with expand/collapse animation
      - Custom/expand-icon: Shows expand/collapse icon
      - Tray: Icon size 12px, spacing 14px
    - **Pulseaudio**: Shows volume icon (headphones when connected, speaker otherwise)
      - Left click: opens wiremix (or bluetui with right click)
      - Scroll: adjust volume
      - Tooltip shows volume percentage
    - **Network**: Shows connection status icon
      - Icons for disconnected, ethernet, wifi (various strengths)
      - Left click: opens impala
      - Shows SSID for wifi, IP for ethernet
    - **Battery**: Shows battery icon with percentage
      - Icons for charging and default states
      - Left click: opens wlogout (exit menu)
      - Tooltip shows power draw/charge rate
      - Warning at 20%, critical at 10%
  - **Styling**:
    - Uses `mocha.css` (Catppuccin Mocha) for colors
    - Additional styling in `style.css` for specific module appearances
  - **Scripts**:
    - `sysmenu.sh`: Provides a system menu for power options, etc.
    - `media.sh`: Controls media playback and returns metadata

## Installed Packages
Waybar package is required. See the native packages list for the exact version.

## Usage
Waybar starts automatically with Hyprland. It updates dynamically based on system state.
Click on modules for various functions as described above.