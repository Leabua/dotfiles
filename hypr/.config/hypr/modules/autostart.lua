hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd(
		"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE && systemctl --user start hyprland-session.target"
	)
	-- dark mode for every app (portal-aware apps read color-scheme) + no min/max/close buttons on GTK headerbars
	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark && gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark && gsettings set org.gnome.desktop.wm.preferences button-layout ''")
	hl.exec_cmd("qs -p $HOME/.config/quickshell/minimalBar")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch $HOME/dotfiles/scripts/cliphist-export-live")
	hl.exec_cmd(
		"eval $(gnome-keyring-daemon --start --components=secrets) && systemctl --user import-environment GNOME_KEYRING_CONTROL SSH_AUTH_SOCK"
	)
end)
