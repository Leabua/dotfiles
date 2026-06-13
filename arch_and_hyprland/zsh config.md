# Zsh Configuration

## Overview
Zsh with vi bindings, powerlevel10k prompt, zoxide navigation, fzf, autosuggestions, syntax highlighting, and Catppuccin Mocha syntax colors.

## Configuration
- **`~/.zshrc`**
- Powerlevel10k instant prompt sourced from cache if available.
- `bindkey -v` — vi mode (ESC for normal, i for insert).
- History: 1000 lines, stored in `~/.histfile`.
- Completion: `compinit` loaded.

### PATH
- `~/.npm-global/bin`, `~/.dotfiles/scripts`, `~/.local/bin`, `$PNPM_HOME`.

### SSH
- `SSH_AUTH_SOCK` set to `$XDG_RUNTIME_DIR/ssh-agent.socket`.
- Actual agent spawning happens in compositor autostart (niri/hyprland), not zsh.

### Tmux
- If `tmux` is installed and no tmux session is active, auto-attaches or creates a new session.

### Theme
- Powerlevel10k sourced from `/usr/share/zsh-theme-powerlevel10k/`.
- `~/.p10k.zsh` loaded if present.
- `POWERLEVEL9K_INSTANT_PROMPT=quiet`.

### Plugins
| Plugin | Source |
|--------|--------|
| zoxide | `zoxide init zsh` (smart `z`/`cd`) |
| fzf completion | `/usr/share/fzf/completion.zsh` |
| fzf key bindings | `/usr/share/fzf/key-bindings.zsh` |
| Catppuccin Mocha syntax highlighting | `~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh` |
| zsh-autosuggestions | `/usr/share/zsh/plugins/zsh-autosuggestions/` |
| zsh-history-substring-search | `/usr/share/zsh/plugins/zsh-history-substring-search/` |
| zsh-syntax-highlighting | `/usr/share/zsh/plugins/zsh-syntax-highlighting/` |

### Aliases
| Alias | Command |
|-------|---------|
| `bonsai` | `cbonsai --screensaver` |
| `dc` | `z ~/dev/courses/` |
| `dp` | `z ~/dev/projects/` |
| `ff` | `fastfetch` |
| `gravity` | `agy` |
| `hacks` | `cmatrix -b -u 2 -C magenta` |
| `p` | `python3` |
| `py` | `python` |
| `q` / `wq` | `exit` |
| `tmux_kill` | Clear tmux resurrect data + kill server |
| `weather` | `curl wttr.in` |
| `y` | `yazi` |
| `ga` | `git add .` |
| `gp` | `git push --set-upstream origin HEAD` |
| `gc` | `git add . && git commit -m` |
| `gs` | `git status` |

## Notes
- Aliases `dc` and `dp` rely on zoxide's `z` command.
- `tmux_kill` removes resurrect session files before killing the server, preventing stale sessions on next start.
- Syntax highlighting colors are defined in `~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh`.
