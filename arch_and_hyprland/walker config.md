# Walker Configuration

## Overview
Wayland-native application launcher with prefix-based search modes (files, calculator, web search, clipboard) and Catppuccin Mocha styling.

## Configuration

### `~/.config/walker/config.toml`
- `force_keyboard_focus = true`, `selection_wrap = true`, `hide_action_hints = true`.
- UI: 300×450, centered, windowed (not fullscreen).
- Placeholder: ` Search...`, list text "No Results".
- Max results: 256.
- Default providers: `desktopapplications`, `websearch`.

### Prefix providers
| Prefix | Provider |
|--------|----------|
| `/` | Provider list |
| `.` | Files |
| `=` | Calculator |
| `@` | Web search |
| `$` | Clipboard |

### `style.css` (Catppuccin Mocha)
- **Window**: transparent (shows wallpaper).
- **Container** (`#box`): Base `#1e1e2e`, 2px Lavender border, 16px radius, 12px padding.
- **Search bar** (`#search`/`entry`): Surface `#313244`, Teal bottom border, 10px radius.
- **Rows**: transparent bg, 8px padding, 8px radius.
- **Selected row**: Sky `#89dceb` at 20% opacity background, Sky text bold, Sky outline.

## Notes
- Walker is an alternative to rofi; the Niri config uses its own Noctalia-based launcher, so this walker config may be inactive depending on the active compositor.
