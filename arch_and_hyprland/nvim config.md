# Neovim Configuration

## Overview
Neovim is a hyperextensible text editor based on Vim. This configuration uses Lua for configuration and packs.nvim for plugin management.

## Configuration Files
- `~/.config/nvim/init.lua`: Main entry point that requires configuration modules.
- `~/.config/nvim/lua/config/`: Directory containing Lua configuration modules:
  - `options.lua`: Editor options and settings
  - `keymaps.lua`: Key mappings
  - `lazy.lua`: Plugin configuration using lazy.nvim
  - `autocmds.lua`: Autocommands
- `~/.config/nvim/lua/plugins/`: Directory for plugin specifications
- `~/.config/nvim/lazy-lock.json`: Lock file for plugin versions

## Setup Commands
No special setup commands are required for neovim beyond ensuring the package is installed. Plugin installation happens automatically on first launch.

## Why This Configuration
- Neovim is chosen for its modern features, Lua scripting capability, and vast plugin ecosystem.
- The configuration is modular, separating concerns into different files:
  - **options.lua**: Sets editor preferences like line numbers, tab width, theme, etc.
  - **keymaps.lua**: Defines custom key mappings for improved productivity
  - **lazy.lua**: Configures lazy.nvim plugin manager and lists all plugins with their configurations
  - **autocmds.lua**: Sets up automatic commands for file types and events
- Plugin management uses lazy.nvim for fast startup and efficient plugin loading.
- The configuration aims for a balanced IDE-like experience while maintaining Vim's efficiency.

## Installed Packages
Neovim package is required. See the native packages list for the exact version.

## Usage
Launch neovim from terminal or via Hyprland keybindings. Plugins will install automatically on first run.