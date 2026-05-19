#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Wallpapers"
CONFIG_FILE="$HOME/.config/hypr/hyprpaper.conf"
HYPRLOCK_CONFIG="$HOME/.config/hypr/hyprlock.conf"

shopt -s nullglob
PICS=("$WALLPAPER_DIR"/*.{jpg,jpeg,png,gif})

if [ ${#PICS[@]} -eq 0 ]; then
  notify-send "Hyprpaper" "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

# Extract the current wallpaper path from your block-syntax config
CURRENT_WALLPAPER=$(grep -E '^\s*path\s*=' "$CONFIG_FILE" | awk -F '=' '{print $2}' | xargs)

# Expand '~' to the full /home/user path so it matches the array
CURRENT_WALLPAPER="${CURRENT_WALLPAPER/#\~/$HOME}"

# Find the index of the current wallpaper
INDEX=-1
for i in "${!PICS[@]}"; do
  if [[ "${PICS[$i]}" == "$CURRENT_WALLPAPER" ]]; then
    INDEX=$i
    break
  fi
done

# Calculate the next index
NEXT_INDEX=$(((INDEX + 1) % ${#PICS[@]}))
NEXT_WALLPAPER="${PICS[$NEXT_INDEX]}"

# --- HYPRPAPER IPC ---
# 1. Preload the new wallpaper into memory
hyprctl hyprpaper preload "$NEXT_WALLPAPER"

# 2. Set the new wallpaper (leading comma means all monitors)
hyprctl hyprpaper wallpaper ",$NEXT_WALLPAPER"

# 3. Unload the old wallpaper to free up RAM
if [ -n "$CURRENT_WALLPAPER" ] && [ "$CURRENT_WALLPAPER" != "$NEXT_WALLPAPER" ]; then
  hyprctl hyprpaper unload "$CURRENT_WALLPAPER"
fi

# --- HYPRLOCK PERSISTENCE ---
# Safely find the 'background {' block in hyprlock.conf and update the path
if [ -f "$HYPRLOCK_CONFIG" ]; then
  sed -i '/^[[:space:]]*background[[:space:]]*{/,/}/ s|^\([[:space:]]*path[[:space:]]*=[[:space:]]*\).*|\1'"$NEXT_WALLPAPER"'|' "$HYPRLOCK_CONFIG"
fi

# --- HYPRPAPER PERSISTENCE ---
# Overwrite the config file using the correct block syntax so it survives a reboot
cat <<EOF >"$CONFIG_FILE"
splash = false

wallpaper {
    monitor = 
    path = $NEXT_WALLPAPER
    fit_mode = cover
}
EOF

notify-send "Wallpaper Updated" "$(basename "$NEXT_WALLPAPER")" -i "$NEXT_WALLPAPER"
