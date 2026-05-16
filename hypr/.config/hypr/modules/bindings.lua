---------------
--- Bindings---
---------------

local bind = hl.bind

-- rofi
bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("pkill rofi || ~/.config/waybar/scripts/sysmenu.sh"))
bind("SUPER + SPACE", hl.dsp.exec_cmd(MENU))
bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("pkill rofi || /home/leabua/.dotfiles/scripts/cliphist-rofi"))
bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("pkill rofi || /home/leabua/.dotfiles/scripts/cliphist-rofi"))

-- wallpaper switcher
bind("SUPER + SHIFT + P", hl.dsp.exec_cmd("~/.dotfiles/scripts/rotate_wallpaper.sh"))

-- generics
bind("SUPER + Return", hl.dsp.exec_cmd(TERMINAL))
bind("SUPER + SHIFT + O", hl.dsp.exec_cmd("obsidian"))
bind("SUPER + SHIFT + F", hl.dsp.exec_cmd(FILEMANAGER))
bind("SUPER + SHIFT + B", hl.dsp.exec_cmd(BROWSER))
bind(
	"SUPER + SHIFT + M",
	hl.dsp.exec_cmd(
		"/usr/bin/chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --profile-directory=Default --app-id=blgdilankhbcpipclgpdndahbehalgkh"
	)
)
