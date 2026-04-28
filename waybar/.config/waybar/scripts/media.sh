#!/bin/bash
# Event-driven media module for waybar
# Dependencies: playerctl

playerctl --follow metadata --format '{{status}}' 2>/dev/null | while read -r STATUS_EVENT; do
  sleep 0.3
  STATUS=$(playerctl status 2>/dev/null)
  ARTIST=$(playerctl metadata artist 2>/dev/null)
  TITLE=$(playerctl metadata title 2>/dev/null)
  PLAYER=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)

  if [[ "$STATUS" != "Playing" && "$STATUS" != "Paused" ]]; then
    printf '{"text":"","class":"stopped","tooltip":""}\n'
    continue
  fi

  case "$PLAYER" in
  "spotify") ICON="" ;;
  "firefox") ICON="" ;;
  "chrome") ICON="" ;;
  *) ICON="" ;;
  esac

  if [[ -n "$ARTIST" ]]; then
    FULL_TEXT="$ARTIST - $TITLE"
  else
    FULL_TEXT="$TITLE"
  fi

  MAX_LEN=40
  if ((${#FULL_TEXT} > MAX_LEN)); then
    TRUNCATED_TEXT="${FULL_TEXT:0:$MAX_LEN}..."
  else
    TRUNCATED_TEXT="$FULL_TEXT"
  fi

  DISPLAY_TEXT="$ICON $TRUNCATED_TEXT"
  TOOLTIP="${ARTIST}\n${TITLE}\n\nPlayer: ${PLAYER}\nStatus: ${STATUS}"
  CLASS=$([[ "$STATUS" == "Playing" ]] && echo "playing" || echo "paused")

  ESCAPED_TEXT=$(echo "$DISPLAY_TEXT" | sed 's/\\/\\\\/g; s/"/\\"/g')
  ESCAPED_TOOLTIP=$(echo "$TOOLTIP" | sed 's/\\/\\\\/g; s/"/\\"/g')

  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$ESCAPED_TEXT" "$ESCAPED_TOOLTIP" "$CLASS"
done
