-----------------
--- Utilities ---
-----------------

local bind = hl.bind

-- hide waybar
bind("SUPER + SHIFT + SPACE", hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))

-- toggle transparency
bind("SUPER + BACKSPACE", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }))

-- lock
bind("SUPER + CTRL + L", hl.dsp.exec_cmd("hyprlock"))

-- volume and brightness
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true })
bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { repeating = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { repeating = true })

-- media
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- power button
bind("XF86PowerOff", hl.dsp.exec_cmd("~/.config/waybar/scripts/sysmenu.sh --power"), { locked = true })

-- screenshots
bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty --filename -'))
bind(
	"SUPER + Print",
	hl.dsp.exec_cmd('grim - | wl-copy && notify-send "Screenshot" "Monitor copied to clipboard" -i clipboard')
)
