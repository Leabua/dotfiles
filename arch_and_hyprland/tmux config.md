# Tmux Configuration

## Overview
Terminal multiplexer with smart vim-aware pane navigation, tmux-power status bar (Tokyo Night blue), and auto-reload.

## Configuration
- **`~/.config/tmux/tmux.conf`**
- `detach-on-destroy on` — cleanly closes when last session ends.
- `mouse on`.
- `base-index 1`, `pane-base-index 1`, `renumber-windows on`.
- True color: `default-terminal "tmux-256color"` with `RGB` override.
- `focus-events on` — required for neovim integration.

## Key bindings

### Splits (no prefix, current directory)
| Key | Action |
|-----|--------|
| `Prefix \` | Vertical split |
| `Prefix -` | Horizontal split |

### Smart pane navigation (Neovim-aware)
Detects if neovim is running in the pane; if so, passes the key through instead of switching panes.

| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Navigate pane left/down/up/right |
| `Alt+\` | Previous pane |
| `Copy-mode M-h/j/k/l` | Navigate panes from copy mode |

### Window switching (no prefix)
| Key | Action |
|-----|--------|
| `Alt+0–9` | Switch to window N |

### OpenCode quick launch
| Key | Action |
|-----|--------|
| `Alt+o` | 25% vertical split, launch opencode |

## Plugins
| Plugin | Purpose |
|--------|---------|
| `tmux-plugins/tpm` | Plugin manager (prefix + I to install) |
| `b0o/tmux-autoreload` | Auto-reloads config on file change |
| `wfxr/tmux-power` | Status bar theme (Tokyo Night `blue`) |

### Status bar (tmux-power)
- Custom background: `#1a1a1a`.
- Left sections cleared entirely (`status-left ""`).
- Right sections show RAM usage (`󰍛 N%`) and uptime (`󰔛 H:MM`).
- Active window tab: bold `#I:#W` with Tokyo Night blue (`#7aa2f7`) foreground on `#1a1a1a` background, flat right-edge triangle.
- Inactive window tabs: muted foreground on `#1a1a1a`.

## Notes
- `tmux-autoreload` watches `tmux.conf` and applies changes without needing a manual reload.
- Window tab overrides must appear *after* the `tpm` run line.
- The `is_vim` check supports `view`, `nvim`, `vim`, and `vimdiff` processes.
