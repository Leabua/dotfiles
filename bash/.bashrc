# shellcheck shell=bash
# Interactive configuration only; scripts keep their own shell settings.
[[ $- == *i* ]] || return

# NixOS usually loads this automatically; the guard also makes re-sourcing safe.
if [[ -r /etc/bashrc && -z ${__ETC_BASHRC_SOURCED:-} ]]; then
  source /etc/bashrc
fi

# History and standard Bash editing (Ctrl+U / Ctrl+K clear either side).
HISTFILE="$HOME/.bash_history"
HISTSIZE=1000
HISTFILESIZE=1000
HISTCONTROL=ignoreboth
shopt -s histappend checkwinsize
set -o emacs

case ":$PATH:" in
  *":$HOME/dotfiles/scripts:"*) ;;
  *) export PATH="$HOME/dotfiles/scripts:$PATH" ;;
esac
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.local/bin" ;;
esac
# Multiplexers started before the login-shell change can inherit SHELL=zsh.
export SHELL
SHELL=$(command -v bash)

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

# NixOS initializes Ble.sh, FZF, and Starship in /etc/bashrc. These fallbacks
# also support Arch without initializing any of them twice.
if [[ -z ${BLE_VERSION:-} && $TERM != dumb ]]; then
  for ble_file in /usr/share/blesh/ble.sh /run/current-system/sw/share/blesh/ble.sh; do
    if [[ -r $ble_file ]]; then
      # shellcheck disable=SC1090
      source "$ble_file"
      break
    fi
  done
  unset ble_file
fi
if command -v fzf >/dev/null 2>&1 && ! declare -F fzf-file-widget >/dev/null; then
  eval "$(fzf --bash)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi
# Keep virtualenv/Conda from inserting a second prompt before Starship.
export VIRTUAL_ENV_DISABLE_PROMPT=1
export CONDA_CHANGEPS1=false
if command -v starship >/dev/null 2>&1 && ! declare -F starship_precmd >/dev/null; then
  eval "$(starship init bash)"
fi

# NixOS maintenance.
alias clean='sudo nix-collect-garbage -d && sudo nixos-rebuild boot --flake "$HOME/dotfiles/nixos#nixos"'
alias nixconf='nvim "$HOME/dotfiles/nixos"'
alias rebuild='sudo nixos-rebuild switch --flake "$HOME/dotfiles/nixos#nixos" --log-format internal-json -v |& nom --json'
alias search="nix search nixpkgs"
alias upgrade='nix flake update --flake "$HOME/dotfiles/nixos" && rebuild'

# Everyday shortcuts.
alias catall="fd -t f -X tail -n +1 | nvim"
alias ff="fastfetch"
alias p="python3"
alias py="python"
alias tmux_kill="rm -rf ~/.local/share/tmux/resurrect/*.txt && tmux kill-server"
alias q="exit"
alias wq="exit"
alias weather="curl wttr.in"
alias y="yazi"

# Git and trackpad shortcuts.
alias ga="git add ."
alias gc="git add . && git commit -m"
alias gp="git push --set-upstream origin HEAD"
alias gs="git status"
alias trackpad="sudo modprobe -r psmouse && sudo modprobe psmouse"
