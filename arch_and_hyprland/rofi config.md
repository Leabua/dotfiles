# Rofi Configuration

## Overview
Application launcher, clipboard picker, and system menu — all styled with Catppuccin Mocha.

## Configuration

### `config.rasi` — Application launcher (drun)
- Font: SF Pro Bold 11. Icons enabled, icon size 36px.
- 4-column, 2-row grid, horizontal fill. No scrollbar. `fixed-height = false` (shrinks to 1 row if ≤4 results).
- Window: 600px wide, 1px border, 12px radius, border color = `@blue`.
- Input bar: Surface0 background, 8px radius, placeholder "Search apps...".
- `hover-select = true`, `kb-cancel = "Escape,MousePrimary"`, history disabled.
- Display: Arch logo (``) with `{name}` format.

### `clipboard.rasi` — Clipboard picker
- Font: JetBrainsMono Nerd Font 11.
- Single-column list, 6 visible lines, 6px spacing.
- Window: 400px wide, 2px border. Icon preview 40px.
- Placeholder: "Search clipboard...".

### `sysmenu.rasi` — System/power menu
- Font: JetBrainsMono Nerd Font Bold 12.
- Positioned at top-left (x=10, y=11), 300px wide, 2px border, 8px radius.
- 4 items (lines=4), no icons.

### `catppuccin-mocha.rasi` — Shared theme variables
Imports full Catppuccin Mocha palette (rosewater through crust).

## Key bindings
Rofi is launched via Hyprland/niri keybindings:
- `SUPER + SPACE` — Application launcher
- `SUPER + ALT + SPACE` — System menu
- `SUPER + SHIFT + V/C` — Clipboard picker

## Notes
- The `@selected` color (blue `#89b4fa`) is used for borders, selection highlights, and error messages.
- `hover-select` makes the selection follow the mouse cursor automatically.
- `MousePrimary` is bound to both cancel (click outside) and accept — clicking an entry accepts, clicking the backdrop dismisses.
