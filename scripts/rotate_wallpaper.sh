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

# Only (re)start the daemon if it isn't already running
if ! pgrep -x awww-daemon &>/dev/null; then
  awww-daemon &>/dev/null &
  disown
  sleep 0.5
fi

# Read current wallpaper from state file
CURRENT_WALLPAPER=""
[ -f "$STATE_FILE" ] && read -r CURRENT_WALLPAPER <"$STATE_FILE"

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

# Set wallpaper via awww — no -o/--outputs flag means it targets ALL active
# monitors by default, which is what fixes the single-monitor problem.
if ! awww img "$NEXT_WALLPAPER" --transition-type fade --transition-duration 1; then
  notify-send "Wallpaper" "Failed to set wallpaper via awww"
  exit 1
fi

# Persist current wallpaper to state file
echo "$NEXT_WALLPAPER" >"$STATE_FILE"

# Update hyprlock config
if [ -f "$HYPRLOCK_CONFIG" ]; then
  sed -i '/^[[:space:]]*background[[:space:]]*{/,/}/ s|^\([[:space:]]*path[[:space:]]*=[[:space:]]*\).*|\1'"$NEXT_WALLPAPER"'|' "$HYPRLOCK_CONFIG"
fi

# Update quickshell bar colors
matugen image "$NEXT_WALLPAPER"

notify-send "Wallpaper Updated" "$(basename "$NEXT_WALLPAPER")"
