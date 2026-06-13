# Niri Configuration

## Overview
Scrollable-tiling Wayland compositor configured for an independent dual-monitor workflow with Noctalia shell integration.

## Configuration
- **`~/.config/niri/config.kdl`** (KDL format).

### Environment & Autostart
- Cursor: Bibata-Modern-Ice, size 20, GDK scale 1.
- On start: SSH key added, gnome-keyring-daemon started, dbus env exported, nm-applet, hypridle, cliphist (text + image), polkit agent.
- `qs -c noctalia-shell` provides bar, launcher, lockscreen, wallpaper, notifications, and control center.
- Waybar and swww are commented out — replaced by Noctalia.

### Input
- Keyboard: US layout, Caps→Escape, repeat 60/300ms, numlock on.
- Touchpad: natural scroll, tap-to-click, disable-while-typing.
- Mouse: no natural scroll.
- `focus-follows-mouse` with warp-to-focus.

### Monitors
- `HDMI-A-1`: 1920×1080@60, positioned above laptop (`0x-1080`).
- `eDP-1` (laptop): 1920×1080@60, at origin.

### Window Decoration
- **Focused windows**: opacity 0.90, 6px radius, focus ring 2px with green→blue gradient (`a6e3a1`→`89b4fa`) at 45°, no blur, no shadow, `draw-border-with-background = false` (fixes color issues on focused windows).
- **Unfocused windows**: opacity 0.85, 6px radius, no blur, no shadow, no focus ring.

### Layout
- Gaps 10, never center focused column.
- Preset column widths: 0.5, 1.0. Default: 0.5.
- Preset window heights: 0.5, 1.0.
- Borders disabled (use focus ring instead).
- Hot corners off.

### Cursor
- Hide on key press, hide after 10s inactivity.

## Key bindings

### Application launchers
| Binding | Action |
|---------|--------|
| `Mod + Return` | Open terminal (ghostty) |
| `Mod + Space` | Noctalia app launcher |
| `Mod + Alt + Space` | Noctalia session/power menu |
| `Mod + Shift + V/C` | Noctalia clipboard picker |
| `Mod + Shift + O` | Obsidian |
| `Mod + Shift + F` | Nautilus |
| `Mod + Shift + B` | Zen Browser |
| `Mod + Shift + P` | Random wallpaper (Noctalia) |
| `Mod + Shift + M` | Apple Music PWA |
| `Print` | Area screenshot → satty |
| `Mod + Print` | Full screenshot → clipboard |

### System utilities (Noctalia)
| Binding | Action |
|---------|--------|
| `Mod + Shift + Return` | Toggle bar |
| `Mod + Alt + L` | Lock screen |
| `Mod + Alt + C` | Toggle control center |
| `Mod + Alt + N` | Toggle notification history |
| `Mod + Alt + M` | Toggle system monitor |

### Audio / Brightness / Media
| Binding | Action |
|---------|--------|
| `XF86AudioRaiseVolume` | Volume +5% (capped) |
| `XF86AudioLowerVolume` | Volume −5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Brightness +5% |
| `XF86MonBrightnessDown` | Brightness −5% |
| `XF86AudioNext/Pause/Play/Prev` | Media control |
| `XF86PowerOff` | Noctalia session menu |

All audio/brightness/media keys allow-when-locked (`XF86PowerOff` excluded).

### Window management
| Binding | Action |
|---------|--------|
| `Mod + W` | Close window |
| `Mod + F` | Fullscreen |
| `Mod + O` | Toggle overview |
| `Mod + Shift + Q` | Quit niri |
| `Mod + H/L` | Focus column left/right |
| `Mod + K/J` | Focus workspace up/down |
| `Mod + Shift + K/J` | Focus monitor up/down |
| `Mod + Ctrl + K/J/H/L` | Focus monitor up/down/left/right |
| `Mod + Shift + H/L` | Move column left/right |
| `Mod + , / .` | Consume / expel window from column |
| `Mod + Ctrl + Shift + K/J/H/L` | Move window to monitor up/down/left/right |
| `Mod + - / =` | Resize column width −/+ 100 |
| `Mod + Shift + - / =` | Resize window height −/+ 100 |
| `Mod + R/T` | Switch preset column width |
| `Mod + Shift + R/T` | Switch preset window height |

### Workspaces
| Binding | Action |
|---------|--------|
| `Mod + 1–0` | Focus workspace 1–10 |
| `Mod + Shift + 1–0` | Move window to workspace and follow |
| `Mod + Ctrl + Shift + 1–0` | Move window to workspace silently |

### Window rules
- wiremix, bluetui, impala (ghostty with matching title) — open floating.
- sysmenu-tui (ghostty) — open floating.
- localsend — open floating.
- NautilusPreviewer — open floating.
- Apple Music PWA — `open-focused = false` (prevent focus steal on launch).

## Notes
- Replaces an earlier Hyprland + Waybar setup. Noctalia (`qs`) handles most UI: bar, launcher, lockscreen, notifications, wallpapers, control center, system monitor.
- Focus ring gradient matches the Hyprland active border (green→blue) for visual consistency.
- The `consume-window-into-column` / `expel-window-from-column` bindings (`,` / `.`) leverage niri's scrollable-column layout.
