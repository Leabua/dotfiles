# Scripts Configuration

## Overview
Utility scripts called by keybindings for clipboard history and wallpaper rotation.

## `cliphist-rofi`
Rofi frontend for cliphist clipboard history.
- Lists entries from `cliphist list`.
- Binary data (images) are decoded to cached PNG thumbnails (`~/.cache/cliphist_thumbs/`) and displayed with a ` Image` label and icon.
- Text entries shown inline.
- Rofi returns the selected index; script maps it back to the original cliphist line, decodes it, and pipes to `wl-copy`.
- Uses `~/.dotfiles/rofi/rofi/clipboard.rasi` theme.
- Shows a notification if history is empty.

Launched via `SUPER + SHIFT + V` or `SUPER + SHIFT + C`.

## `rotate_wallpaper.sh`
Cycles through wallpapers in `~/Wallpapers` (`*.{jpg,jpeg,png,gif}`).
- Uses `awww-daemon`/`awww img` with fade transition (1s).
- Tracks current wallpaper via `~/.cache/awww_current_wallpaper`.
- Updates `hyprlock.conf` by sed-replacing the `path` line in the `background` block so the lock screen matches.
- Sends a notification with the new wallpaper name and preview icon.

Launched via `SUPER + SHIFT + P`.

## Notes
- Both scripts should be executable and in `~/.local/bin/` or similar PATH entry.
- The wallpaper script references `awww` (not `swww` or `hyprctl`) for the daemon and image setting.
