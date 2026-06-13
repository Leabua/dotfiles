# Mako Configuration

## Overview
Lightweight Wayland notification daemon with Catppuccin Mocha styling and per-app timeout overrides.

## Configuration
- **`~/.config/mako/config`**
- Font: JetBrainsMono Nerd Font 10.
- Colors (Catppuccin Mocha): background `#1e1e2e` (Base), text `#cdd6f4` (Text), default border `#89dceb` (Sky), progress bar `over #313244` (Surface0).
- Notification size: 300×100, margin 10, padding 15, border 2px with 8px radius.
- `ignore-timeout=1` — mako controls all timeouts, not applications.
- `default-timeout=4000` — 4 seconds.

### Criteria overrides
| Match | Changes |
|-------|---------|
| `urgency=high` | Red border (`#f38ba8`), 10s timeout (overrides apps that send 0) |
| `expiring=0` | Force 4s timeout on notifications that declare themselves static |
| `app-name=Satty` | Green border (`#a6e3a1`), 2s timeout (screenshot confirmation) |

## Notes
- The `expiring=0` rule prevents "persistent" notifications from lingering indefinitely — all notifications expire.
- High urgency gets 10s instead of the default 4s for important alerts.
