#!/usr/bin/env sh
# herdr-nav.sh <left|right|up|down>
# vim-aware herdr pane navigation - the herdr equivalent of vim-tmux-navigator.
#
# If the focused pane's foreground process is (n)vim, forward the matching
# alt+h/j/k/l chord into the pane so its own mapping moves the split (and, at
# the edge, hands focus back to herdr). Otherwise focus the herdr pane in the
# requested direction.
set -eu

dir=${1:?usage: herdr-nav.sh <left|right|up|down>}

case "$dir" in
  left)  key=alt+h ;;
  down)  key=alt+j ;;
  up)    key=alt+k ;;
  right) key=alt+l ;;
  *) echo "herdr-nav: bad direction '$dir'" >&2; exit 1 ;;
esac

info=$(herdr pane process-info --current 2>/dev/null || true)
[ -n "$info" ] || exit 0

is_vim=$(printf '%s' "$info" | jq -r '
  [ .result.process_info.foreground_processes[]?
    | .name, .cmdline, (.argv // [])[] ] | any(test("(^|/)(g?view|n?vim?x?)(diff)?$"; "i"))' 2>/dev/null || printf 'false')

pane_id=$(printf '%s' "$info" | jq -r '.result.process_info.pane_id' 2>/dev/null || true)

if [ "$is_vim" = "true" ] && [ -n "$pane_id" ]; then
  herdr pane send-keys "$pane_id" "$key"
else
  herdr pane focus --direction "$dir" --current
fi
