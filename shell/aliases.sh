# shellcheck shell=bash
# Aliases shared by bash/.bashrc and zsh/.zshrc. Edit them here, not in either rc file.

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
