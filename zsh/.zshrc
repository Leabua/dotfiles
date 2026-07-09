# ── p10k instant prompt ──────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── history ──────────────────────────────────────────────────
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# ── input & completion ───────────────────────────────────────
bindkey -v
zstyle :compinstall filename '/home/leabua/.zshrc'
autoload -Uz compinit
compinit

# ── path ─────────────────────────────────────────────────────
export PATH="$HOME/dotfiles/scripts:$PATH"
export PATH="$PATH:/home/leabua/.local/bin"

# ── ssh agent (gcr/gnome-keyring) ────────────────────────────
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

# ── tmux autostart ───────────────────────────────────────────
if command -v tmux &>/dev/null && [[ -z "$TMUX" ]]; then
  tmux attach 2>/dev/null || tmux new-session
fi

# ── prompt (powerlevel10k) ───────────────────────────────────
# _src sources the first candidate that exists, so this file stays portable
# across arch (/usr/share) and nixos (/run/current-system/sw/share).
_src() { local f; for f in "$@"; do [[ -r $f ]] && { source "$f"; return 0; }; done; return 1 }

_src \
  /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme \
  /run/current-system/sw/share/zsh/themes/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# ── tools & plugins ──────────────────────────────────────────
eval "$(zoxide init zsh)"

_src /usr/share/fzf/completion.zsh   /run/current-system/sw/share/fzf/completion.zsh
_src /usr/share/fzf/key-bindings.zsh /run/current-system/sw/share/fzf/key-bindings.zsh

_src \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /run/current-system/sw/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

_src \
  /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh \
  /run/current-system/sw/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# zsh-syntax-highlighting must be sourced last
_src \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── nixos ────────────────────────────────────────────────────
alias nixconf="nvim $HOME/dotfiles/nixos"
# GC old generations, then rebuild the boot menu so it drops entries for the
# now-deleted generations (nix-collect-garbage alone leaves stale boot entries).
alias clean="sudo nix-collect-garbage -d && sudo nixos-rebuild boot --flake $HOME/dotfiles/nixos#nixos"
alias rebuild="sudo nixos-rebuild switch --flake $HOME/dotfiles/nixos#nixos"
alias search="nix search nixpkgs"

# ── general QoL ──────────────────────────────────────────────
alias catall="find . -type f -exec tail -n +1 {} + | nvim"
alias ff="fastfetch --logo nixos"
alias p="python3"
alias py="python"
alias tmux_kill="rm -rf ~/.local/share/tmux/resurrect/*.txt && tmux kill-server"
alias q="exit"
alias wq="exit"
alias weather="curl wttr.in"
alias y="yazi"

# ── git QoL ──────────────────────────────────────────────────
alias ga="git add ."
alias gc="git add . && git commit -m"
alias gp="git push --set-upstream origin HEAD"
alias gs="git status"

# ── hp pavilion trackpad reset ───────────────────────────────
alias trackpad="sudo modprobe -r psmouse && sudo modprobe psmouse"
