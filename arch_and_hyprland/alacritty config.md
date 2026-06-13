# Alacritty Configuration

## Overview
GPU-accelerated terminal emulator configured with dynamic theming from Omarchy, JetBrainsMono Nerd Font, and minimal window chrome.

## Configuration
- **`~/.config/alacritty/alacritty.toml`** — Main config file.
- `general.import` loads `~/.config/omarchy/current/theme/alacritty.toml` so the theme can be swapped centrally.
- `env.TERM = "xterm-256color"` ensures full color support and broad terminal compatibility.
- Font: JetBrainsMono Nerd Font at size 14 for readable code with icon glyphs.
- Window padding `x=8, y=3` for comfortable spacing; `decorations = "None"` removes title bar for a cleaner look; `opacity = 0.9` for slight transparency.

## Key bindings
| Binding | Action |
|---------|--------|
| `Shift + Insert` | Paste |
| `Ctrl + Insert` | Copy |

These mirror common terminal copy/paste conventions without occupying more standard shortcuts.

## Notes
- Theme is managed externally by Omarchy — changing the active theme automatically updates Alacritty's colors on restart.
- No special setup commands beyond installing the `alacritty` package.
