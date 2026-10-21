# shellcheck shell=bash
# Keep only history suggestions and ordinary Tab completion. Starship owns the
# prompt, FZF owns fuzzy search, and typed input uses the terminal foreground.
bleopt highlight_syntax= highlight_filename= highlight_variable=
bleopt complete_auto_complete=1 complete_auto_complete_opts=syntax-disabled
bleopt complete_auto_delay=200
bleopt complete_auto_menu= complete_menu_complete= complete_menu_filter=
bleopt complete_ambiguous= edit_magic_expand=history
bleopt edit_bell= edit_marker= edit_marker_error= exec_elapsed_enabled=
bleopt exec_exit_mark= prompt_eol_mark= prompt_status_line=

# Suggestions stay dim with no background.
ble-face -s auto_complete fg=8,bg=none
ble-face -s region_insert fg=8,bg=none
ble-face -s disabled fg=8

# Backport Ghostty's prompt-marker fix for Ble.sh without replacing its shell
# integration. This runs once, after Ghostty has installed its hooks. Already
# fixed versions are left alone: https://github.com/ghostty-org/ghostty/pull/11644
_dotfiles_ghostty_prompt_compat() {
  local definition before after
  if definition=$(declare -f __ghostty_precmd); then
    # shellcheck disable=SC2016
    before='builtin printf "\e]133;A;redraw=last;cl=line;aid=%s\a" "$BASHPID"'
    after='builtin printf "\e]133;P;k=i\a"'
    if [[ $definition == *"$before"* && $definition != *"$after"* ]]; then
      builtin eval -- "${definition/"$before"/"$after"}"
    fi
  fi
  blehook PRECMD-=_dotfiles_ghostty_prompt_compat
  unset -f _dotfiles_ghostty_prompt_compat
}
blehook PRECMD!=_dotfiles_ghostty_prompt_compat
