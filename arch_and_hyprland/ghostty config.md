# Ghostty Configuration

## Overview
Fast terminal emulator configured with Aizen Dark theme, Nerd Font support, and minimal window chrome.

## Configuration
- **`~/.config/ghostty/config`**
- Theme: `Aizen Dark` (commented-out alternatives: Ayu, Catppuccin Mocha, Modus Vivendi Tinted, Dracula).
- Font: `IoskeleyMono Nerd Font`, Regular weight, size 13. Ligatures enabled via `font-feature = ["calt", "liga"]`. Commented alternatives: JetBrainsMono Nerd Font, Zed Mono.
- Window: no decorations, padding-y = 2, fully opaque (`background-opacity = 1`), inherits working directory on new window.
- `resize-overlay = never` — suppresses the resize indicator.
- `confirm-close-surface = false` — no prompt on close.
- Cursor: block style, no blink.

## Key bindings
Uses Ghostty defaults.

## Notes
- `shell-integration-features = no-cursor,ssh-env` — disables cursor sequence integration (avoids conflicts) but keeps SSH terminfo passthrough.
- Multiple themes and fonts are kept commented out for quick switching.
