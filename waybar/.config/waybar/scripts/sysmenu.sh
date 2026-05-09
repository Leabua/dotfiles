#!/bin/bash

# ==============================================================================
# Rofi Theme & UI Functions
# ==============================================================================
theme="$HOME/.config/rofi/sysmenu.rasi"

# Helper function to spawn the menu
show_menu() {
  echo -e "$1" | rofi -dmenu -i -p "$2" -theme "$theme"
}

# ==============================================================================
# Menu Variables
# ==============================================================================
menu_main="󰀻  Apps\n󰏓  Packages\n󱐋  Power Profile\n󰐥  Power"
menu_packages="󰏓  Native Apps (pacseek)\n󰖟  PWAs (Web Apps)"
menu_pwa="󰐕  Create New PWA\n󰆴  Delete PWA"
menu_power_profile="󰾆  Performance\n󰾅  Balanced\n󰾄  Efficient"
menu_power="󰒲  Hibernate\n󰑓  Reboot\n󰍃  Log Out\n󰐥  Poweroff"

# ==============================================================================
# Logic Tree
# ==============================================================================
chosen_main=$(show_menu "$menu_main" "System")

case "$chosen_main" in
*"Apps")
  # Triggers your main centered app launcher
  rofi -show drun -theme ~/.config/rofi/config.rasi
  ;;

*"Packages")
  chosen_pkg=$(show_menu "$menu_packages" "Packages")
  case "$chosen_pkg" in
  *"Native Apps"*)
    # Changed to --title
    ghostty --title=sysmenu-tui -e pacseek
    ;;
  *"PWAs"*)
    chosen_pwa_act=$(show_menu "$menu_pwa" "PWAs")
    case "$chosen_pwa_act" in
    *"Create"*)
      # Changed to --title and added quotes for the linter!
      ghostty --title=sysmenu-tui -e "$HOME/.config/waybar/scripts/pwa-builder.sh"
      ;;
    *"Delete"*)
      # Changed to --title
      ghostty --title=sysmenu-tui -e yazi "$HOME/.local/share/applications/"
      ;;
    esac
    ;;
  esac
  ;;

*"Power Profile")
  # Get the current active profile from the daemon
  current_prof=$(powerprofilesctl get)

  # Reconstruct the menu strings with a visual indicator for the active one
  p_text="Performance"
  b_text="Balanced"
  e_text="Efficient"

  # Add italics and an indicator if it matches the current profile
  [[ "$current_prof" == "performance" ]] && p_text="<i>󰾆  Performance *</i>" || p_text="󰾆  Performance"
  [[ "$current_prof" == "balanced" ]] && b_text="<i>󰾅  Balanced *</i>" || b_text="󰾅  Balanced"
  [[ "$current_prof" == "power-saver" ]] && e_text="<i>󰾄  Efficient *</i>" || e_text="󰾄  Efficient"

  menu_power_profile="${p_text}\n${b_text}\n${e_text}"

  # Show the menu (Rofi supports basic Pango markup like <i> with the -markup-rows flag)
  chosen_prof=$(echo -e "$menu_power_profile" | rofi -dmenu -i -p "Profile" -theme "$theme" -markup-rows)

  case "$chosen_prof" in
  *"Performance"*) powerprofilesctl set performance ;;
  *"Balanced"*) powerprofilesctl set balanced ;;
  *"Efficient"*) powerprofilesctl set power-saver ;;
  esac
  ;;

*"Power")
  chosen_power=$(show_menu "$menu_power" "Power")
  case "$chosen_power" in
  *"Hibernate") systemctl hibernate ;;
  *"Reboot") systemctl reboot ;;
  *"Log Out") hyprctl dispatch exit ;;
  *"Poweroff") systemctl poweroff ;;
  esac
  ;;
esac
