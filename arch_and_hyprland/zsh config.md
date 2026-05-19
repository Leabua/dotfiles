# Zsh Configuration

## Overview
Zsh is a powerful shell that serves as both an interactive shell and a scripting language interpreter. This configuration enhances the default zsh experience with plugins, themes, and customizations for productivity.

## Configuration Files
- `~/.zshrc`: Main zsh configuration file.
- `~/.zsh/`: Directory containing additional zsh customizations (syntax highlighting, etc.).

## Setup Commands
No special setup commands are required for zsh beyond ensuring the package is installed. However, some features require additional packages:
- Powerlevel10k theme
- zoxide (smart cd)
- fzf (fuzzy finder)
- Various zsh plugins (autosuggestions, history substring search, syntax highlighting)

These are typically installed via the package manager and listed in the packages files.

## Why This Configuration
- This zsh configuration is designed for efficiency, aesthetics, and seamless integration with the development workflow:
  - **Instant Prompt**: 
    - Sources powerlevel10k instant prompt for faster startup
    - Checks for readable cache file in `${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh`
  - **History Settings**:
    - `HISTFILE=~/.histfile`: Custom history file location
    - `HISTSIZE=1000` and `SAVEHIST=1000`: 1000 lines of history in memory and saved
  - **Key Bindings**:
    - `bindkey -v`: Uses vi key bindings (vim-like navigation)
  - **Completion System**:
    - `zstyle :compinstall filename '/home/leabua/.zshrc'`: Sets compinstall filename
    - `autoload -Uz compinit && compinit`: Initializes advanced completion
  - **Path Configuration**:
    - Adds `~/.npm-global/bin` to PATH for global npm packages
    - Adds `~/.dotfiles/scripts` to PATH for custom scripts
    - Adds `~/.local/bin` to PATH for local binaries
    - Configures PNPM_HOME and adds it to PATH if not already present
  - **SSH Agent**:
    - Starts ssh-agent with 1-hour timeout if not running
    - Sources ssh-agent environment if socket doesn't exist
  - **TMUX Integration**:
    - If tmux is installed and no session exists, attaches to existing or creates new session
  - **Theme and Appearance**:
    - Sources powerlevel10k theme (`/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme`)
    - Sources `~/.p10k.zsh` for powerlevel10k configuration if it exists
    - Sets `POWERLEVEL9K_INSTANT_PROMPT=quiet` for quieter instant prompt
  - **Navigation Enhancements**:
    - `eval "$(zoxide init zsh)"`: Initializes zoxide for smarter cd command
  - **Fuzzy Finder**:
    - Sources fzf completion and key bindings for enhanced fuzzy finding
  - **Syntax Highlighting and Plugins**:
    - Sources Catppuccin Mocha Zsh syntax highlighting (`~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh`)
    - Sources zsh-autosuggestions for fish-like autosuggestions
    - Sources zsh-history-substring-search for up/down arrow history search
    - Sources zsh-syntax-highlighting for real-time command syntax highlighting
  - **Aliases**:
    - Directory shortcuts: `dc` (~/dev/courses/), `dp` (~/dev/projects/)
    - `ff`: fastfetch (system information)
    - `p` and `py`: python3 and python
    - `tmux_kill`: Clears tmux resurrect data and kills server
    - `vim`: Aliased to nvim (Neovim)
    - `q` and `wq`: exit shell
    - `weather`: Shows weather via wttr.in
    - `y`: yazi (terminal file manager)
    - Git aliases: `ga` (git add .), `gp` (git push), `gc` (git add and commit)
- This configuration provides a rich, feature-filled shell experience that enhances productivity while maintaining familiarity for users coming from bash or other shells.

## Installed Packages
Zsh package is required. See the native packages list for the exact version.
Additional packages for features:
- zsh-theme-powerlevel10k (for the theme)
- zoxide (for smarter cd)
- fzf (for fuzzy finding)
- zsh-autosuggestions
- zsh-history-substring-search
- zsh-syntax-highlighting
- Any packages providing the syntax highlighting file in ~/.zsh/

## Usage
- Start a new terminal session to load the configuration
- Press ESC for vi navigation mode, or use i to insert
- Use up/down arrows to search through history (substring search)
- Start typing a command and press ↑/↓ to search history with that prefix
- Use tab for completion
- Use Ctrl+r for fzf-based history search
- Use zoxide commands: `z <directory>` to jump to frequently used directories
- Use fzf for fuzzy finding in various contexts
- Enjoy syntax highlighting as you type
- Use autosuggestions (gray text) and accept with →