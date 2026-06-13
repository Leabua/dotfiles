# Pacseek Configuration

## Overview
Terminal-based Arch Linux package manager frontend (official repos + AUR), using yay as the backend and a custom Catppuccin Mocha color scheme.

## Configuration

### `~/.config/pacseek/config.json`
- **Backend**: `yay -S` for install, `yay -Rns` for uninstall, `yay` for system upgrade.
- **AUR**: Uses `aurapi.moson.org/rpc` (faster community API), 5s timeout, 500ms search delay.
- **Search**: `Contains` mode by package `Name`, max 500 results.
- **Cache**: 10-minute expiry, enabled.
- **Appearance**: Custom color scheme, `Single` border style, `Angled-No-X` glyphs, `Transparent = true`.
- **PKGBUILD**: Shown internally via `curl | less`.
- **News feed**: Disabled.
- **Layout**: `LeftProportion = 4`, window layout not saved.
- `SepDepsWithNewLine = true` — dependencies listed one per line.
- `EnableAutoSuggest = false`, `ComputeRequiredBy = false`.

### `~/.config/pacseek/colors.json` (Catppuccin Mocha)
| Element | Color | Hex |
|---------|-------|-----|
| Accent | Blue | `#89b4fa` |
| Title | Sky | `#89dceb` |
| SearchBar | Base | `#1e1e2e` |
| Repo packages | Green | `#a6e3a1` |
| AUR packages | Mauve | `#cba6f7` |
| Header | Yellow | `#f9e2af` |
| PKGBUILD style | catppuccin-mocha | — |

`Transparent = false` in colors.json (overrides config.json's `true`).

## Notes
- `AurUseDifferentCommands` is false — yay handles both pacman and AUR operations uniformly.
- The `colors.json` transparency is set to false separately from the main config's transparency flag.
