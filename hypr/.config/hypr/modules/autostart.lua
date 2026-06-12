hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("waybar & hyprpaper")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
	hl.exec_cmd(
		"eval $(gnome-keyring-daemon --start --components=secrets) && systemctl --user import-environment GNOME_KEYRING_CONTROL SSH_AUTH_SOCK"
	)
end)
