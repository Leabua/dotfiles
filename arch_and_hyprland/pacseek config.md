# Pacseek Configuration

## Overview
Pacseek is a terminal-based package manager frontend for Arch Linux that provides an interactive interface for searching, installing, and managing packages from both official repositories and the AUR.

## Configuration Files
- `~/.config/pacseek/config.json`: Main configuration file in JSON format.
- `~/.config/pacseek/colors.json`: Color scheme configuration.

## Setup Commands
No special setup commands are required for pacseek beyond ensuring the package is installed.

## Why This Configuration
- Pacseek is chosen for its powerful search capabilities and user-friendly interface for package management.
- The configuration is tailored for optimal usability:
  - **Pacman/AUR Integration**: Configured to use yay for AUR operations (`InstallCommand`: "yay -S", `UninstallCommand`: "yay -Rns", `SysUpgradeCommand`: "yay")
  - **AUR Settings**: Uses moson's AUR RPC for faster requests with appropriate timeouts and delays
  - **Search Behavior**: Set to "Contains" search mode searching by package name with max 500 results
  - **Cache Management**: 10-second cache expiry with caching enabled for performance
  - **Appearance**: Custom color scheme with single borders, transparent background, and angled glyphs
  - **Usability Features**: Disabled news feed to reduce clutter, enabled internal PKGBUILD viewing, and separated dependencies with newlines for readability
- The configuration makes pacseek a powerful yet clean interface for managing Arch Linux packages.

## Installed Packages
Pacseek package is required. See the native packages list for the exact version.

## Usage
Run `pacseek` in terminal to launch the interactive package manager interface.