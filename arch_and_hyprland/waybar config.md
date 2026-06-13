# Waybar Configuration

## Overview
Wayland status bar with Catppuccin Mocha styling, semi-transparent pill modules, and rofi-driven system menu. Font: SF Pro 16px bold.

## Configuration

### `~/.config/waybar/config.jsonc`
- `layer = "top"`, `position = "top"`, `spacing = 0`.
- `reload_style_on_change = true`.

#### Modules-left
**Group `left-pill`** (semi-transparent `crust` background, 16px radius):
- `custom/arch`: Arch logo `` in JetBrainsMono, opens `sysmenu.sh` on click.
- `clock`: `{:%H:%M}` format, right-click opens timezone selector via `omarchy-tz-select`, alt-click shows full date.

**`custom/media`**: Standalone pill — runs `media.sh` (event-driven playerctl output). Click toggles play/pause, right-click next track, scroll adjusts volume 5%. Hidden (opacity 0) when nothing is playing; dimmed when paused.

#### Modules-center
**`hyprland/workspaces`**: Numbered icons 1–9 + 0 for workspace 10. Persistent workspaces 1–5. Active workspace gets teal color and expanded pill. Niri workspaces module present but commented out.

#### Modules-right
Semi-transparent `crust` pill containing:
- **`pulseaudio`**: Volume icon + `{volume}%`. Click opens wiremix in floating ghostty; right-click opens bluetui. Muted state dimmed.
- **`network`**: WiFi SSID or ethernet IP, cycling icons for signal strength. Disconnected shows "No Network" in maroon. Click opens impala.
- **`battery`**: Charging/discharging icons + `{capacity}%`, tooltip shows power draw. Warning at 20% (peach), critical at 10% (red). Click opens wlogout.

#### Unused sections
`group/tray-expander` with `custom/expand-icon` and `tray` are defined but not included in any modules-* list (dead code).

### `style.css`
- Global: `font-family: "SF Pro"`, `font-size: 16`, `background-color: transparent`, no borders.
- Left pill (`#left-pill`): `alpha(@crust, 0.85)`, 16px radius, mauve text.
- Media pill (standalone): same background, fades out when stopped, dims when paused.
- Workspaces: pill with `surface0` border, active button gets teal text + `surface1` background, hover dims.
- Right-side modules: transparent inside the pill container, mauve text.
- Battery warning/critical states use peach/red.

### `mocha.css`
Full Catppuccin Mocha palette variables.

## Scripts

### `sysmenu.sh`
Rofi-based system menu with nested submenus:
- **Apps** → launches rofi drun.
- **Packages** → pacseek (ghostty) or PWA management (create/delete).
- **Power Profiles** → `powerprofilesctl` (performance/balanced/power-saver) with active profile indicator.
- **Power** → Suspend (lock + systemctl suspend), Reboot, Log Out (hyprshutdown or niri msg), Power Off.
- `--power` flag jumps directly to power submenu.

### `media.sh`
Event-driven playerctl metadata display. Listens on all players via `--follow`, outputs JSON with `text`, `class` (playing/paused/stopped), truncates to 40 chars.

### `pwa-builder.sh`
Interactive terminal script that creates Chromium PWA `.desktop` files: prompts for app name, URL, icon URL, downloads the icon, writes a desktop entry.

## Key bindings
Waybar is launched on compositor start. Modules respond to mouse events as documented above.

## Notes
- This config is used under Hyprland. Under Niri, waybar is commented out in favor of Noctalia's bar.
- `group/tray-expander` is a leftover definition — system tray is not displayed.
- The `media.sh` script uses `playerctl --all-players --follow` for live updates without polling.
