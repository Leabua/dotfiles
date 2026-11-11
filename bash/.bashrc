# shellcheck shell=bash
# Interactive configuration only; scripts keep their own shell settings.
[[ $- == *i* ]] || return

# NixOS usually loads this automatically; the guard makes re-sourcing safe.
if [[ -r /etc/bashrc && -z ${__ETC_BASHRC_SOURCED:-} ]]; then
  source /etc/bashrc
fi

# History and Emacs-style line editing (Ctrl+U / Ctrl+K clear either side).
HISTFILE="$HOME/.bash_history"
HISTSIZE=1000
HISTFILESIZE=1000
HISTCONTROL=ignoreboth
shopt -s histappend checkwinsize
set -o emacs

# PATH: personal scripts first, ~/.local/bin last. Added only once.
case ":$PATH:" in
  *":$HOME/dotfiles/scripts:"*) ;;
  *) export PATH="$HOME/dotfiles/scripts:$PATH" ;;
esac
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.local/bin" ;;
esac

# Multiplexers started before the login-shell change can inherit SHELL=zsh.
SHELL=$(command -v bash)
export SHELL

# SSH agent provided by gcr / GNOME Keyring.
if [[ -n ${XDG_RUNTIME_DIR:-} ]]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
fi

# Herdr's terminal needs a terminfo entry Neovim can resolve.
if [[ ${HERDR_ENV:-} == 1 ]]; then
  if infocmp xterm-ghostty >/dev/null 2>&1; then
    export TERM=xterm-ghostty
  else
    export TERM=tmux-256color
  fi
fi

# Tools. NixOS initializes FZF and Starship in /etc/bashrc; these fallbacks
# cover Arch without initializing either twice.
if command -v fzf >/dev/null 2>&1 && ! declare -F fzf-file-widget >/dev/null; then
  eval "$(fzf --bash)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# Prompt: Starship only; stop virtualenv / Conda adding a second prompt.
export VIRTUAL_ENV_DISABLE_PROMPT=1
export CONDA_CHANGEPS1=false
if command -v starship >/dev/null 2>&1 && ! declare -F starship_precmd >/dev/null; then
  eval "$(starship init bash)"
fi
if declare -F starship_precmd >/dev/null; then
  source "$HOME/.config/bash/prompt.sh"
fi

# Aliases.

# NixOS maintenance.
alias rebuild='nixos-rebuild switch --sudo --flake "$HOME/dotfiles/nixos#nixos" --log-format internal-json -v |& nom --json'
alias upgrade='nix flake update --flake "$HOME/dotfiles/nixos" && "$HOME/dotfiles/nixos/update-opencode.sh" && rebuild'
alias update-t3code='nix flake update t3code --flake "$HOME/dotfiles/nixos" && rebuild'
alias clean='sudo nix-collect-garbage -d && nixos-rebuild boot --sudo --flake "$HOME/dotfiles/nixos#nixos"'
alias nixconf='nvim "$HOME/dotfiles/nixos"'
alias search='nix search nixpkgs'

# Everyday shortcuts.
alias catall='fd -t f -X tail -n +1 | nvim'
alias claude2='CLAUDE_CONFIG_DIR="$HOME/.claude_2" claude'
alias ff='fastfetch'
alias p='python3'
alias py='python'
alias q='exit'
alias wq='exit'
alias tmux_kill='rm -rf ~/.local/share/tmux/resurrect/*.txt && tmux kill-server'
alias weather='curl wttr.in'
alias y='yazi'

# Git.
alias ga='git add .'
alias gc='git add . && git commit -m'
alias gp='git push --set-upstream origin HEAD'
alias gs='git status'

# HP Pavilion trackpad reset.
alias trackpad='sudo modprobe -r psmouse && sudo modprobe psmouse'
