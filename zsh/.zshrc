# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/leabua/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
# start editing from here
eval "$(zoxide init zsh)"
source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh


# ---- Aliases ----
alias dc="z ~/dev/courses/"
alias dp="z ~/dev/projects/"
alias ff="fastfetch"
alias p="python3"
alias py="python"
alias tmux_kill="rm -rf ~/.local/share/tmux/resurrect/*.txt && tmux kill-server"
alias vim="nvim"
alias q="exit"
alias weather="curl wttr.in"
alias wq="exit"
alias y="yazi"
#
# git commands.
alias ga="git add ."
alias gp="git push"
alias gc="git add . && git commit -m"

export SSH_AUTH_SOCK=/run/user/1000/ssh-agent.sock
# Created by `pipx` on 2026-05-08 15:05:11
export PATH="$PATH:/home/leabua/.local/bin"

if [ -z "$TMUX" ]; then
  tmux attach || tmux new-session
fi

