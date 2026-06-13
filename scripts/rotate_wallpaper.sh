#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Wallpapers"
STATE_FILE="$HOME/.cache/awww_current_wallpaper"
HYPRLOCK_CONFIG="$HOME/.config/hypr/hyprlock.conf"

shopt -s nullglob
PICS=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,gif})

if [ ${#PICS[@]} -eq 0 ]; then
  notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

# Ensure swww daemon is running
awww-daemon &>/dev/null &
sleep 0.5

# Read current wallpaper from state file
CURRENT_WALLPAPER=""
if [ -f "$STATE_FILE" ]; then
  CURRENT_WALLPAPER=$(cat "$STATE_FILE")
fi

# Find index of current wallpaper
INDEX=-1
for i in "${!PICS[@]}"; do
  if [[ "${PICS[$i]}" == "$CURRENT_WALLPAPER" ]]; then
    INDEX=$i
    break
  fi
done

# Next wallpaper
NEXT_INDEX=$(((INDEX + 1) % ${#PICS[@]}))
NEXT_WALLPAPER="${PICS[$NEXT_INDEX]}"

# Set wallpaper via swww
awww img "$NEXT_WALLPAPER" --transition-type fade --transition-duration 1

# Persist current wallpaper to state file
echo "$NEXT_WALLPAPER" >"$STATE_FILE"

# Update hyprlock config
if [ -f "$HYPRLOCK_CONFIG" ]; then
  sed -i '/^[[:space:]]*background[[:space:]]*{/,/}/ s|^\([[:space:]]*path[[:space:]]*=[[:space:]]*\).*|\1'"$NEXT_WALLPAPER"'|' "$HYPRLOCK_CONFIG"
fi

notify-send "Wallpaper Updated" "$(basename "$NEXT_WALLPAPER")" -i "$NEXT_WALLPAPER"
