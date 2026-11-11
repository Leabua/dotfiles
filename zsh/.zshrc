# p10k instant prompt: must stay at the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History.
HISTFILE="$HOME/.histfile"
HISTSIZE=1000
SAVEHIST=1000

# Input: Emacs keys like Bash (Ctrl+U / Ctrl+K clear either side of the cursor).
bindkey -e
bindkey '^U' backward-kill-line
# Unmatched globs stay literal as in Bash, so pasted or agent commands don't fail.
setopt no_nomatch
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

# Source a file only if it exists, so a missing plugin doesn't break the shell.
_src() { [[ -r $1 ]] && source "$1" }

# Prompt: Powerlevel10k.
_src /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
_src ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Tools and plugins.
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

_src /usr/share/fzf/completion.zsh
_src /usr/share/fzf/key-bindings.zsh

_src /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

_src /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
if (( $+widgets[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# Aliases.

# Arch maintenance (yay wraps pacman and covers the AUR).
alias upgrade='yay -Syu'
alias clean='yay -Yc && yay -Sc'
alias search='yay -Ss'

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

# zsh-syntax-highlighting must be sourced last.
_src /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

unfunction _src
