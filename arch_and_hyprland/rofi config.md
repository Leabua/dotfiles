# Rofi Configuration

## Overview
Rofi is a window switcher, application launcher and dmenu replacement. It provides a highly customizable interface for launching applications, switching windows, and more.

## Configuration Files
- `~/.config/rofi/config.rasi`: Main configuration file in Rasi format.
- `~/.config/rofi/catppuccin-mocha.rasi`: Color scheme import (Catppuccin Mocha).
- `~/.config/rofi/clipboard.rasi`: Configuration for clipboard mode.
- `~/.config/rofi/sysmenu.rasi`: Configuration for system menu mode.

## Setup Commands
No special setup commands are required for rofi beyond ensuring the package is installed.

## Why This Configuration
- Rofi is chosen for its flexibility and powerful features as an application launcher and window switcher.
- The configuration uses the Catppuccin Mocha theme for visual consistency across the desktop.
- Key aspects of this configuration:
  - **Theme Import**: Imports Catppuccin Mocha colors for consistent theming
  - **Global Styling**: Sets background, foreground, and selected colors from the theme
  - **Behavior Configuration**:
    - Sets modi to "drun" (application launcher) as default
    - Enables icons for better visual recognition
    - Customizes application launcher display with Arch Linux logo
    - Uses "{name}" format for clean application names
    - Sets font to SF Pro Bold 11 for readability
    - Enables hover-select and mouse-based interactions
    - Sets Escape and MousePrimary as cancel keys
    - Disables history for privacy
  - **Window Appearance**:
    - Fixed width of 600px for consistency
    - 1px border with 12px radius for modern look
    - Border color follows selection color from theme
  - **Layout and Spacing**:
    - 15px spacing between elements for comfortable interaction
    - 15px padding inside main container
    - Transparent mainbox background to show wallpaper
    - Input bar with 12px vertical and 15px horizontal padding
    - 8px border radius on input bar for modern appearance
    - Search placeholder text: "Search apps..."
  - **List View Configuration**:
    - 4 columns and 2 lines for compact display
    - Horizontal flow layout filling items left-to-right
    - No scrollbar for cleaner look when results fit
    - Vertical layout within each element
    - Fixed columns to prevent resizing
    - Allows shrinking to 1 row when results are few
  - **Element Styling**:
    - 10px spacing and 12px horizontal/5px vertical padding
    - 8px border radius for rounded elements
    - Transparent background with pointer cursor on hover
    - Selected elements use theme's selected color
    - Icons sized at 36px for good visibility
    - Text centered both vertically and horizontally
  - **Error Messaging**:
    - 15px padding with 2px border
    - 10px border radius
    - Uses selected color for border and background from theme

## Installed Packages
Rofi package is required. See the native packages list for the exact version.

## Usage
- Launch application launcher: `rofi -show drun` (or via Hyprland keybindings)
- Launch window switcher: `rofi -show window`
- Other modes can be launched similarly by changing the `-show` parameter