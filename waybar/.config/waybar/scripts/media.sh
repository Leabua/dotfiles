#!/bin/bash
# Event-driven media module for waybar
# Dependencies: playerctl

playerctl --all-players --follow metadata --format '{{playerName}} {{status}} {{title}}' 2>/dev/null | while read -r line; do
  sleep 0.1

  # Extract the player that fired the event
  PLAYER=$(echo "$line" | awk '{print $1}')

  STATUS=$(playerctl --player="$PLAYER" status 2>/dev/null)
  ARTIST=$(playerctl --player="$PLAYER" metadata artist 2>/dev/null)
  TITLE=$(playerctl --player="$PLAYER" metadata title 2>/dev/null)

  if [[ "$STATUS" != "Playing" && "$STATUS" != "Paused" ]]; then
    printf '{"text":"","class":"stopped","tooltip":""}\n'
    continue
  fi

  case "$PLAYER" in
  "spotify") ICON="" ;;
  "firefox") ICON="" ;;
  "chromium" | "chrome") ICON="" ;;
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
  CLASS=$([[ "$STATUS" == "Playing" ]] && echo "playing" || echo "paused")
  ESCAPED_TEXT=$(echo "$DISPLAY_TEXT" | sed 's/\\/\\\\/g; s/"/\\"/g')

  printf '{"text":"%s","tooltip":"","class":"%s"}\n' "$ESCAPED_TEXT" "$CLASS"
done
