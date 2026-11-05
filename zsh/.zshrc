# Not the login shell any more (Bash is); kept working for Arch or switching back.

# p10k instant prompt: must stay at the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History.
HISTFILE="$HOME/.histfile"
HISTSIZE=1000
SAVEHIST=1000

# Input and completion: Vi keys.
bindkey -v
autoload -Uz compinit
compinit

# PATH: personal scripts first, ~/.local/bin last. Duplicates are dropped.
typeset -U path
path=("$HOME/dotfiles/scripts" $path "$HOME/.local/bin")

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

# Source the first readable file of each group: Arch path, then NixOS path.
_src() { local f; for f in "$@"; do [[ -r $f ]] && { source "$f"; return 0; }; done; return 1 }

# Prompt: Powerlevel10k.
_src \
  /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme \
  /run/current-system/sw/share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme
_src ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Tools and plugins.
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

_src /usr/share/fzf/completion.zsh   /run/current-system/sw/share/fzf/completion.zsh
_src /usr/share/fzf/key-bindings.zsh /run/current-system/sw/share/fzf/key-bindings.zsh

_src \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /run/current-system/sw/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

_src \
  /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh \
  /run/current-system/sw/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Aliases shared with bash.
_src "$HOME/dotfiles/shell/aliases.sh"

# zsh-syntax-highlighting must be sourced last.
_src \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

unfunction _src
