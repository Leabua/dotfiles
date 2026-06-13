# Wiremix Configuration

## Overview
Terminal-based PipeWire/PulseAudio mixer with mouse support and volume boosting up to 150%.

## Configuration
- **`~/.config/wiremix/wiremix.toml`**
- `mouse = true` — click on sliders and switches.
- `peaks = "auto"` — automatic peak visualization.
- `tab = "playback"` — starts on the playback tab.
- `max_volume_percent = 150.0`, `enforce_max_volume = false` — allows boosting past 100%.
- `lazy_capture = false` — captures all streams immediately.
- Remote and FPS commented out (use defaults).

## Key bindings
| Key | Action |
|-----|--------|
| `Esc` | Exit |

## Notes
- Launched via waybar pulseaudio module click (opens in floating ghostty with `--title=wiremix-term`).
- Hyprland window rule floats and sizes it to 600×400 at position (1307,51).
