# shellcheck shell=bash
# This prompt only displays the directory and Git state. Avoid Starship's
# command timers, job counting, and a second process for an empty right prompt.
# Keep the existing registered hooks, including Ghostty's shell integration.
starship_preexec() { :; }

starship_precmd() {
  local command_status=$? command_pipes=("${PIPESTATUS[@]}")
  if [[ ${BLE_ATTACHED:-} && ${#BLE_PIPESTATUS[@]} -gt 0 ]]; then
    command_pipes=("${BLE_PIPESTATUS[@]}")
  fi

  "${starship_precmd_user_func:-:}"
  if [[ ${STARSHIP_PROMPT_COMMAND:-} ]]; then
    _starship_set_return "$command_status"
    eval "$STARSHIP_PROMPT_COMMAND"
  fi

  PS1="$(command starship prompt \
    --terminal-width="${COLUMNS:-80}" \
    --status="$command_status" \
    --pipestatus="${command_pipes[*]}" \
    --shlvl="$SHLVL")"
}

# In sessions without Ble.sh, remove just Starship's timer from PS0. Preserve
# Ghostty's command marker and any other pre-command prompt content.
# shellcheck disable=SC2016
_dotfiles_starship_timer='${STARSHIP_START_TIME:$((STARSHIP_START_TIME="$(starship_preexec_ps0)",STARSHIP_PREEXEC_READY=0,0)):0}'
PS0=${PS0#"$_dotfiles_starship_timer"}
unset _dotfiles_starship_timer
