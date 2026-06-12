# Satty Configuration

## Overview
Satty is a feature-rich, keyboard-driven screenshot and annotation tool for Wayland. It allows capturing screenshots, adding annotations, and copying or saving the results.

## Configuration Files
- `~/.config/satty/config.toml`: Main configuration file in TOML format.

## Setup Commands
No special setup commands are required for satty beyond ensuring the package is installed.

## Why This Configuration
- Satty is chosen for its powerful annotation capabilities and keyboard-driven workflow.
- The configuration is optimized for Hyprland and a clean, efficient experience:
  - **General Settings**:
    - `fullscreen = false`: Starts in windowed mode by default for flexibility
    - `floating-hack = true`: Ensures compatibility with Hyprland's floating window management
    - `early-exit = true` and `early-exit-save-as = true`: Exists immediately after saving or copying to clipboard for efficiency
    - `corner-roundness = 12`: Matches the 12px rounded corners used elsewhere in the desktop theme
    - `initial-tool = "rectangle"`: Starts with rectangle selection tool for common use case
    - `copy-command = "wl-copy"`: Uses wl-copy for Wayland clipboard integration
    - `annotation-size-factor = 2`: Makes annotations twice as thick for better visibility
    - `output-filename = "/home/leabua/Pictures/Screenshots/satty-%Y-%m-%d_%H:%M:%S.png"`: Saves screenshots to a dedicated folder with timestamped filenames
    - `save-after-copy = false`: Prevents saving duplicates when only clipboard copy is needed
    - `default-hide-toolbars = false`: Shows toolbars by default for discoverability
    - `actions-on-enter = ["save-to-clipboard", "exit"]`: Press Enter to save to clipboard and exit
    - `actions-on-escape = ["exit"]`: Press Escape to exit without saving
    - `no-window-decoration = true`: Removes window decorations for cleaner appearance
    - `zoom-factor = 1.1`: Provides slight zoom for precise annotations
  - **Keybinds**: Intuitive single-key shortcuts for all tools (pointer, crop, brush, line, arrow, rectangle, ellipse, text, marker, blur, highlight)
  - **Color Palette**: Uses Catppuccin Mocha colors for visual consistency with the rest of the desktop:
    - Blue (#89b4fa), Pink (#f5c2e7), Mauve (#cba6f7), Red (#f38ba8), Green (#a6e3a1), Peach (#fab387)
- This configuration makes satty a powerful yet unobtrusive tool that integrates seamlessly with the Hyprland workflow, providing keyboard-driven screenshot capture and annotation with beautiful, theme-consistent colors.

## Installed Packages
Satty package is required. See the native packages list for the exact version.

## Usage
- Launch satty via Hyprland keybindings or from terminal
- Use keyboard shortcuts to select tools and annotate
- Press Enter to save to clipboard and exit, or Escape to cancel
- Screenshots are saved to `~/Pictures/Screenshots/` with timestamps when not copying to clipboard only