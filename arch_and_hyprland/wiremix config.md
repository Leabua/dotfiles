# Wiremix Configuration

## Overview
Wiremix is a terminal-based mixer for PipeWire/PulseAudio that provides a visual interface for managing audio streams and volume levels.

## Configuration Files
- `~/.config/wiremix/wiremix.toml`: Main configuration file in TOML format.

## Setup Commands
No special setup commands are required for wiremix beyond ensuring the package is installed.

## Why This Configuration
- Wiremix is chosen for its intuitive terminal-based interface for audio management.
- The configuration is kept simple but functional:
  - **Audio Settings**:
    - `#remote = "pipewire-0"`: Commented out, uses default PipeWire connection
    - `#fps = 60.0`: Commented out, uses default refresh rate
    - `mouse = true`: Enables mouse support for interacting with the interface
    - `peaks = "auto"`: Automatic peak detection for audio visualization
    - `char_set = "default"`: Uses default character set for display
    - `theme = "default"`: Uses default theme
    - `tab = "playback"`: Starts on playback tab (rather than capture or devices)
    - `max_volume_percent = 150.0`: Allows volume boosting up to 150%
    - `enforce_max_volume = false`: Does not enforce the maximum volume limit (allows exceeding 100%)
    - `lazy_capture = false`: Does not use lazy capture (captures all streams immediately)
  - **Keybindings**:
    - `{ key = "Esc", action = "Exit" }`: Press Escape to exit the program
- This configuration makes wiremix a flexible audio mixer that works well in a terminal environment, with mouse support for easy interaction and volume boosting capabilities when needed.

## Installed Packages
Wiremix package is required. See the native packages list for the exact version.

## Usage
- Launch wiremix from terminal or via Hyprland keybindings (often bound to right-click on the volume icon in waybar)
- Use mouse or keyboard to navigate:
  - Mouse: Click on volume sliders, switches, etc.
  - Keyboard: Navigate with arrow keys, adjust values, etc.
  - Escape: Exit the program
- Tabs allow switching between playback, capture, and devices views