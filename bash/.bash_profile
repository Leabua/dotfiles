# shellcheck shell=bash
# Login shells (including tmux panes) use the same config as other Bash shells.
if [[ -r "$HOME/.profile" ]]; then
  source "$HOME/.profile"
fi
if [[ -r "$HOME/.bashrc" ]]; then
  source "$HOME/.bashrc"
fi
