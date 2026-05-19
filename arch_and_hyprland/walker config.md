# Walker Configuration

## Overview
Walker is a Wayland-native application launcher and file finder. It provides a quick and efficient way to launch applications, search files, and perform various actions from the keyboard.

## Configuration Files
- `~/.config/walker/config.toml`: Main configuration file in TOML format.
- `~/.config/walker/style.css`: CSS-like styling file for custom appearance.

## Setup Commands
No special setup commands are required for walker beyond ensuring the package is installed.

## Why This Configuration
- Walker is chosen for its speed, flexibility, and Wayland-native implementation.
- The configuration is tailored for an efficient, keyboard-driven workflow:
  - **General Settings**:
    - `force_keyboard_focus = true`: Ensures walker takes keyboard focus when launched
    - `selection_wrap = true`: Allows wrapping selection from bottom to top and vice versa
    - `hide_action_hints = true`: Hints at the bottom are hidden for cleaner look
    - `theme = "~/.config/walker/style.css"`: Uses custom CSS file for styling
  - **UI Settings**:
    - `fullscreen = false`: Launches in windowed mode rather than fullscreen
    - `width = 300`: Fixed width of 300 pixels
    - `height = 450`: Fixed height of 450 pixels
    - `align_x = "center"` and `align_y = "center"`: Centers walker on screen
  - **Placeholders**:
    - Default input placeholder: " Search..." (search icon)
    - Default list placeholder: "No Results"
  - **Providers** (sources of information):
    - `max_results = 256`: Maximum number of results to show
    - `default = ["desktopapplications", "websearch"]`: Shows applications and web search by default
    - **Prefix Providers** (special searches triggered by prefixes):
      - `/`: Shows list of available providers
      - `.`: File browser for local files
      - `=`: Calculator for quick computations
      - `@`: Web search (searches with default search engine)
      - `$`: Clipboard history (shows recent clipboard items)
  - **Styling** (`style.css`):
    - Uses Catppuccin Mocha-inspired colors:
      - Base: #1e1e2e (dark background)
      - Surface: #313244 (slightly lighter for inputs)
      - Text: #cdd6f4 (light foreground)
      - Lavender: #b4befe (purple accent)
      - Teal: #94e2d5 (teal accent)
      - Sky: #89dceb (blue accent)
    - **Window**: Transparent background to show wallpaper behind
    - **Main Container (#box)**:
      - Background: base color
      - Border: 2px solid lavender with 16px radius
      - Padding: 12px
    - **Search Bar (#search)**:
      - Background: surface color
      - Text: text color
      - Border radius: 10px
      - Padding: 10px
      - Bottom border: 2px solid teal
    - **Search Input (entry)**:
      - Inherits search bar styling
    - **List Items**:
      - Transparent background
      - Rows: 8px padding, 2px margin, 8px radius, text color
      - Selected row: Sky background at 20% opacity, sky text, thin sky outline, bold selected labels
- This configuration makes walker a powerful, visually consistent launcher that integrates seamlessly with the Hyprland workflow, providing quick access to applications, files, web search, calculations, and clipboard history with a beautiful, theme-consistent interface.

## Installed Packages
Walker package is required. See the native packages list for the exact version.

## Usage
- Launch walker via Hyprland keybindings or from terminal
- By default, shows applications and web search
- Use prefixes for specialized searches:
  - `. ` to browse files
  - `= ` for calculations (e.g., `= 2+2`)
  - `@ ` for web search
  - `$ ` for clipboard history
  - `/ ` to see all available providers
- Navigation with arrow keys, Enter to select, Escape to close