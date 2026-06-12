# Mako Configuration

## Overview
Mako is a lightweight notification daemon for Wayland. It handles desktop notifications with customizable appearance and behavior.

## Configuration Files
- `~/.config/mako/config`: Main configuration file.

## Setup Commands
No special setup commands are required for mako beyond ensuring the package is installed and the notification daemon is running.

## Why This Configuration
- Mako is chosen for its simplicity, performance, and Wayland-native implementation.
- The configuration uses the Catppuccin Mocha color scheme for visual consistency.
- Key aspects of this configuration:
  - Font: JetBrainsMono Nerd Font at size 10 for readability
  - Window dimensions: 300px width, 100px height with appropriate margins and padding
  - Border styling: 2px width, 8px radius for modern appearance
  - Timeout behavior: Ignores application timeouts (ignore-timeout=1) with default 4-second timeout
  - Urgency levels: High urgency notifications get extended 10-second timeout
  - Special handling: Satty app notifications get green border and 2-second timeout for quick feedback
- The configuration ensures consistent, attractive notifications that don't overstay their welcome while still being noticeable when important.

## Installed Packages
Mako package is required. See the native packages list for the exact version.

## Usage
Mako runs as a daemon and displays notifications automatically. Configuration is applied on restart.