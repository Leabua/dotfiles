# Fastfetch Configuration

## Overview
Fastfetch is a system information tool similar to neofetch but written in C for better performance. It displays system information in an aesthetically pleasing way.

## Configuration Files
- `~/.config/fastfetch/config.jsonc`: Main configuration file in JSONC format (JSON with comments).

## Setup Commands
No special setup commands are required for fastfetch beyond ensuring the package is installed.

## Why This Configuration
- Fastfetch is chosen for its speed and customizability compared to alternatives like neofetch.
- The configuration uses JSONC format which allows for comments, making it easier to understand and modify.
- Key aspects of this configuration:
  - Custom header with hardware section title in blue
  - Separator set to a single space for compact display
  - Modules include CPU, GPU, memory, storage, battery, etc. with appropriate icons and colors
  - Logo padding adjusted for better alignment
  - Various system information modules are enabled with customized formatting

## Installed Packages
Fastfetch package is required. See the native packages list for the exact version.

## Usage
Run `fastfetch` in terminal to display system information.