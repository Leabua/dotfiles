# Hyprland Configuration

## Overview
Dynamic tiling Wayland compositor configured modularly via Lua. Dual-monitor setup with Catppuccin Mocha-inspired lock screen, custom animation curves, and per-app window rules.

## Configuration

### Entry point: `~/.config/hypr/hyprland.lua`
Defines four program variables used across modules:
- `BROWSER = "helium-browser"`, `FILEMANAGER = "nautilus"`, `MENU = "rofi -show drun"`, `TERMINAL = "ghostty"`
- Sets cursor env vars: `XCURSOR_SIZE`/`HYPRCURSOR_SIZE = 20`, `XCURSOR_THEME = "Bibata-Modern-Ice"`
- Requires 8 module files from `modules/`.

### `modules/autostart.lua`
On compositor start:
- Exports `WAYLAND_DISPLAY` and `XDG_CURRENT_DESKTOP` via dbus.
- Launches `waybar`, `hyprpaper`, `nm-applet`, `hypridle`.
- Starts `cliphist` store for both text and image clipboard history.
- Starts `polkit-kde-authentication-agent-1` for privilege escalation.
- Starts `gnome-keyring-daemon` and imports its env vars into systemd.

### `modules/bindings.lua`
| Binding | Action |
|---------|--------|
| `SUPER + ALT + SPACE` | System menu (sysmenu.sh) |
| `SUPER + SPACE` | Application launcher (rofi drun) |
| `SUPER + SHIFT + V` / `C` | Clipboard history (cliphist-rofi) |
| `SUPER + SHIFT + P` | Rotate wallpaper |
| `SUPER + Return` | Open terminal (ghostty) |
| `SUPER + SHIFT + O` | Open Obsidian |
| `SUPER + SHIFT + F` | Open file manager (nautilus) |
| `SUPER + SHIFT + B` | Open browser (helium) |
| `SUPER + SHIFT + M` | Apple Music PWA (Chromium app mode) |

### `modules/inputs.lua`
- Keyboard: US layout, Caps Lock swapped to Escape, repeat rate 60/300ms, numlock on.
- Mouse: `follow_mouse = 1` (focus follows mouse), touchpad with natural scroll.
- Cursor: hide on key press after 10s inactivity.
- Gesture: 3-finger horizontal swipe switches workspaces.

### `modules/looknfeel.lua`
- Borders: 2px, active border gradient green→blue (`a6e3a1` → `89b4fa`) at 45°.
- Gaps: inner 5, outer 10.
- Opacity: active 0.9, inactive 0.85.
- Rounding: 7px with `rounding_power = 8` (softer corners).
- Blur and shadows disabled.
- Animations enabled with custom bezier curves (`easeOutQuint`, `easeInOutCubic`, `linear`, `almostLinear`, `quick`) plus one spring curve (`easy`). Each animation leaf (border, windows, fade, layers, workspaces, zoom) has individually tuned speed and bezier.
- Master layout: new windows open as slave on top, orientation left, `mfact = 0.5`.
- Dwindle: `force_split = 2` (smart split).

### `modules/monitors.lua`
- `eDP-1` (laptop): 1920×1080@60, scale 1.
- `HDMI-A-1` (external): 1920×1080@60, positioned above laptop (`0x-1080`), scale 1.
- Workspaces 1–3 → HDMI-A-1, workspaces 4–5 → eDP-1.

### `modules/tiling.lua`
| Binding | Action |
|---------|--------|
| `SUPER + W` | Close window |
| `SUPER + O` | Toggle float |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + H/J/K/L` | Focus left/down/up/right |
| `SUPER + SHIFT + H/J/K/L` | Swap window left/down/up/right |
| `SUPER + T` (code:20/21) | Resize horizontal |
| `SUPER + SHIFT + T` (code:20/21) | Resize vertical |
| `SUPER + 1–9` | Switch to workspace N |
| `SUPER + SHIFT + 1–9` | Move window to workspace N and follow |
| `SUPER + SHIFT + CTRL + 1–9` | Move window to workspace N, stay |
| `SUPER + 0` | Go to workspace 10 |
| `SUPER + SHIFT + 0` | Move window to workspace 10 |
| `SUPER + S` | Toggle special workspace (scratchpad) |
| `SUPER + SHIFT + S` | Move window to scratchpad |
| `SUPER + drag` (mouse:272) | Drag floating window |
| `SUPER + right-drag` (mouse:273) | Resize window |

### `modules/utilities.lua`
| Binding | Action |
|---------|--------|
| `SUPER + SHIFT + SPACE` | Toggle waybar visibility |
| `SUPER + BACKSPACE` | Toggle window transparency |
| `SUPER + CTRL + L` | Lock screen (hyprlock) |
| `XF86AudioRaiseVolume` | Volume +5% (wpctl, capped at 100%) |
| `XF86AudioLowerVolume` | Volume −5% (wpctl) |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86MonBrightnessUp` | Brightness +5% |
| `XF86MonBrightnessDown` | Brightness −5% |
| `XF86AudioNext/Pause/Play/Prev` | Media control (playerctl) |
| `XF86PowerOff` | Power menu |
| `Print` | Area screenshot → satty editor |
| `SUPER + Print` | Full screenshot → clipboard |

### `modules/windowrules.lua`
- **Suppress maximize events globally** — prevents apps from overriding tiling.
- **Fix xwayland drags** — no-focus for empty xwayland floaters (stops invisible windows stealing focus).
- **hyprland-run** — float and reposition the launcher popup.
- **wiremix, bluetui, impala** — float ghostty windows with matching titles, positioned at (1307, 51), sized 600×400 (wiremix) or 600×800 (bluetui, impala).
- **sysmenu-tui** — float centered 900×600.
- **localsend** — float centered 900×600.
- **NautilusPreviewer** — float centered 900×600.
- **Apple Music PWA** — sent to workspace 5 silently, no shadow, opaque.

### `hypridle.conf`
| Timeout | Action |
|---------|--------|
| 2.5 min | Start hyprlock if not running |
| 5 min | Lock session via loginctl |
| 5.5 min | DPMS off; on resume: DPMS on + restore brightness |

`before_sleep_cmd` locks before suspend; `inhibit_sleep = 3` waits for lock.

### `hyprlock.conf`
- Catppuccin Mocha base background with 2-pass blur.
- Profile photo (`lea1.jpg`), circular (rounding = −1), Lavender border, centered with vertical offset.
- Password input: rounded, Mauve outline, Surface0 fill, enter/check green, fail red with attempt count.
- Fingerprint auth enabled.
- `ignore_empty_input = true` — dismisses lock on empty Enter press.

### `hyprpaper.conf`
Single wallpaper with `fit_mode = cover`, splash disabled.

### `hyprsunset.conf`
Blue-light filter activates at 07:00 in `identity` mode (preserves color accuracy while shifting temperature).

### `.luarc.json`
Lua LSP workspace config pointing to `/usr/share/hypr/stubs` for type info and declaring `hl` as a global.

## Notes
- Lua-based config requires `hyprland>0.48` (or the Lua dispatch patch).
- `.luarc.json` enables IDE support for Hyprland's `hl` API.
- The master layout `new_status = "slave"` combined with `new_on_top = true` keeps new windows below the current one but stacked at the top of the slave area.
