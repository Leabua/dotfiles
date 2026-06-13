# Btop Configuration

## Overview
Resource monitor showing CPU, memory, disks, network, and processes in the terminal.

## Configuration
- **`~/.config/btop/btop.conf`** — All settings defined; no defaults left unchanged.
- Catppuccin Mocha theme via `color_theme`. `theme_background = false` so terminal background transparency shows through.
- `truecolor = false` — force 256-color mode (avoids rendering issues in some terminals).
- `shown_boxes = "cpu net proc"` — memory, disks, and battery are hidden from the default view; they overlay on demand.
- `graph_symbol = "braille"` for highest-resolution graphs; per-box graph symbols left at `"default"` to inherit.
- `rounded_corners = true` for modern box styling.
- `update_ms = 2000` — 2-second refresh for stable graph samples.
- Processes: sorted by `memory` descending, shown with color gradient, per-core CPU, memory in bytes, CPU graph per process.
- CPU graph: upper/lower on `"Auto"`, lower inverted, uptime shown, frequency in `"first"` core mode, temperature checked with core temps.
- Memory: shown as graphs, swap included and displayed as a disk, physical disks filtered via fstab.
- Network: auto-rescaling with sync between up/down.
- Battery: shown with wattage.
- `clock_format = "%X"` — current time displayed at top.
- `log_level = "WARNING"` to reduce noise in logs.
- `save_config_on_exit = true` so runtime changes persist.

## Key bindings
Uses default btop key bindings (`vim_keys = false`).

## Notes
- Config is self-contained — changes made in the UI are persisted to this file on exit.
