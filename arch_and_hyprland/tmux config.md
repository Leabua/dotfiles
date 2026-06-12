# Tmux Configuration

## Overview
Tmux is a terminal multiplexer that allows multiple terminal sessions to be accessed simultaneously in a single window. It is useful for running multiple programs, session persistence, and splitting panes.

## Configuration Files
- `~/.config/tmux/tmux.conf`: Main tmux configuration file.
- `~/.config/tmux/plugins/`: Directory for tmux plugins managed by tpm (tmux plugin manager).

## Setup Commands
Special setup is required for tmux plugins:
```bash
# Install tmux plugin manager (tpm) if not present
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# After configuration changes, install/update plugins with:
# Press prefix + I (capital i) in tmux to install plugins
# Press prefix + U to update plugins
# Press prefix + alt + u to uninstall plugins not in the list
```

## Why This Configuration
- Tmux is configured for optimal usability with sensible defaults and quality-of-life improvements:
  - **Session Management**:
    - `detach-on-destroy on`: Cleanly exits when last session is destroyed instead of leaving empty pane
    - `renumber-windows on`: Automatically renumber windows when one is closed to maintain sequential numbering
  - **Navigation and Usability**:
    - Mouse support enabled for easy resizing and selection
    - Window and pane indexing starts at 1 instead of 0 for more intuitive numbering
    - Improved split pane bindings: `\` for vertical split, `-` for horizontal split (easier to reach than default `%` and `"`)
    - Smart pane navigation that detects if neovim is running and sends keys appropriately:
      - Alt+h/j/k/l to navigate panes (or send to neovim if active)
      - Alt+\ to switch to previous pane
      - Copy-mode versions of navigation keys for use in vi copy mode
    - Window switching with Alt+number (no prefix needed) for quick access
    - Special binding: Alt+o creates a 25% vertical split with opencode instantly launched
  - **Appearance and Compatibility**:
    - True color support enabled for modern terminals
    - Focus events enabled for better neovim integration
    - Status line configured with catppuccin mocha theme for visual consistency
    - Status line shows application, RAM usage, session name, and uptime
  - **Plugin Management**:
    - Uses tpm (tmux plugin manager) for easy plugin installation and updates
    - Installed plugins:
      - `tmux-plugins/tpm`: Plugin manager itself
      - `tmux-plugins/tmux-resurrect`: Persists tmux sessions across restarts
      - `tmux-cpu`: CPU usage monitoring in status line
      - `tmux-battery`: Battery monitoring in status line
      - `catppuccin/tmux`: Catppuccin theme for tmux (mocha variant)

## Installed Packages
Tmux package is required. See the native packages list for the exact version.

## Usage
- Start tmux: `tmux`
- Create new session: `tmux new -s session_name`
- Attach to session: `tmux attach -t session_name`
- List sessions: `tmux ls`
- Kill session: `tmux kill-session -t session_name`

### Key Bindings (Prefix is Ctrl+b by default):
- `Ctrl+b %`: Vertical split (replaced with `\`)
- `Ctrl+b "`: Horizontal split (replaced with `-`)
- `Ctrl+b c`: Create new window
- `Ctrl+b n`: Next window
- `Ctrl+b p`: Previous window
- `Ctrl+b ,`: Rename window
- `Ctrl+b d`: Detach from session
- `Ctrl+b [`: Enter copy mode
- `Alt+o`: Split vertically 25% and launch opencode
- `Alt+h/j/k/l`: Navigate panes (smart - sends to neovim if active)
- `Alt+\`: Switch to previous pane
- `Alt+0-9`: Switch windows directly

### In Copy Mode (vi bindings):
- `h/j/k/l`: Move cursor
- `v`: Start visual selection
- `y`: Yank (copy) selection
- `Enter`: Copy selection and exit copy mode
- `q`: Quit copy mode

## Notes
After installing tmux and copying the configuration, you need to install the plugins:
1. Start tmux: `tmux`
2. Press prefix + I (Ctrl+b then Shift+i) to install plugins
3. Plugins will be automatically sourced on subsequent starts