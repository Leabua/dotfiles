if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v

zstyle :compinstall filename '/home/leabua/.zshrc'

autoload -Uz compinit
compinit

export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.dotfiles/scripts:$PATH"
export PATH="$PATH:/home/leabua/.local/bin"
export PNPM_HOME="/home/leabua/.local/share/pnpm"

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

if command -v tmux &>/dev/null && [[ -z "$TMUX" ]]; then
  tmux attach 2>/dev/null || tmux new-session
fi

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

eval "$(zoxide init zsh)"

source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias bonsai="cbonsai --infinite --live"
alias catall="find . -type f -exec tail -n +1 {} + | nvim"
alias dc="z ~/dev/courses/"
alias dp="z ~/dev/projects/"
alias ff="fastfetch --logo arch3"
alias gravity="agy"
alias hacks="cmatrix -b -u 2 -C magenta"
alias p="python3"
alias py="python"
alias tmux_kill="rm -rf ~/.local/share/tmux/resurrect/*.txt && tmux kill-server"
alias q="exit"
alias weather="curl wttr.in"
alias wq="exit"
alias y="yazi"

alias ga="git add ."
alias gp="git push --set-upstream origin HEAD"
alias gc="git add . && git commit -m"
alias gs="git status"
# Added by Antigravity CLI installer
export PATH="/home/leabua/.local/bin:$PATH"
