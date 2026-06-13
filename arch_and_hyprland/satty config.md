# Satty Configuration

## Overview
Keyboard-driven screenshot annotation tool for Wayland, integrated with Catppuccin Mocha colors and a clipboard-first workflow.

## Configuration
- **`~/.config/satty/config.toml`**

### General
- `fullscreen = false`, `floating-hack = true` (Hyprland compatibility).
- `early-exit = true`, `early-exit-save-as = true` — quits immediately after save or copy.
- `corner-roundness = 12`, `no-window-decoration = true`.
- `initial-tool = "rectangle"`, `annotation-size-factor = 2`.
- `copy-command = "wl-copy"`.
- Output path: `~/Pictures/Screenshots/satty-%Y-%m-%d_%H:%M:%S.png`.
- `save-after-copy = false` — no duplicate save when only copying.
- `default-hide-toolbars = false`.
- `zoom-factor = 1.1`.
- Enter saves to clipboard and exits; Escape exits without saving.

### Key bindings
| Key | Tool |
|-----|------|
| `p` | Pointer |
| `c` | Crop |
| `b` | Brush |
| `i` | Line |
| `z` | Arrow |
| `r` | Rectangle |
| `e` | Ellipse |
| `t` | Text |
| `m` | Marker |
| `u` | Blur |
| `g` | Highlight |

### Color palette (Catppuccin Mocha)
Blue, Pink, Mauve, Red, Green, Peach — sequenced in that order.

## Notes
- Launched via `grim -g "$(slurp)" - \| satty --filename -` for area screenshots.
- The `floating-hack` ensures satty renders correctly under Hyprland's tiling.
