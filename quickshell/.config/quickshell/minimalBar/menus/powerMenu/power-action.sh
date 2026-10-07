#!/bin/sh

run_action() {
    case "$1" in
        suspend)
            if ! pgrep -x hyprlock >/dev/null; then
                hyprlock --grace 0 --immediate-render >/dev/null 2>&1 &
                sleep 0.5
                pgrep -x hyprlock >/dev/null || return 1
            fi
            systemctl suspend
            ;;
        logout)
            if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
                if command -v hyprshutdown >/dev/null 2>&1; then
                    hyprshutdown
                else
                    hyprctl dispatch exit
                fi
            elif [ -n "$NIRI_SOCKET" ]; then
                niri msg action quit
            elif [ -n "$XDG_SESSION_ID" ]; then
                loginctl terminate-session "$XDG_SESSION_ID"
            else
                return 1
            fi
            ;;
        reboot) systemctl reboot ;;
        poweroff) systemctl poweroff ;;
        *) return 1 ;;
    esac
}

run_action "$1" || {
    notify-send -a 'Power Menu' -u critical 'Power action failed' "Could not $1. Check your session permissions."
    exit 1
}
