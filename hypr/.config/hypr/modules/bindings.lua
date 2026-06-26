---------------
--- Bindings---
---------------

local bind = hl.bind

-- rofi
bind("SUPER + SPACE", hl.dsp.exec_cmd(MENU))

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

-- quickshell Bindings
bind("SUPER + ALT+ SPACE", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/onebarV2 ipc call cycleBarLevel cycle"))
bind("SUPER +  N", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/onebarV2 ipc call notifications toggle"))
bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/onebarV2 ipc call clipboard toggle"))
bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/onebarV2 ipc call clipboard toggle"))
-- hide shell bar
bind("SUPER + SHIFT + SPACE", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/onebarV2 ipc call bar toggle"))
