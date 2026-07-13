----------------
--- Bindings ---
----------------
local bind = hl.bind

-- wallpaper switcher
bind("SUPER + P", hl.dsp.exec_cmd("~/dotfiles/scripts/rotate_wallpaper.sh"))

-- generics
bind("SUPER + Return", hl.dsp.exec_cmd(TERMINAL))
bind("SUPER + SHIFT + O", hl.dsp.exec_cmd("obsidian"))
bind("SUPER + SHIFT + F", hl.dsp.exec_cmd(FILEMANAGER))
bind("SUPER +  B", hl.dsp.exec_cmd(BROWSER))

-- quickshell Bindings
bind("SUPER + SPACE", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/minimalBar ipc call launcher toggle")) -- launcher
bind("SUPER + ALT + SPACE", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/minimalBar ipc call rightIsland toggle")) -- toggle right island
bind("SUPER +  N", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/minimalBar ipc call notifications toggle")) -- noti panel
bind("SUPER + C", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/minimalBar ipc call clipboard toggle")) -- clipboard secondary
bind("SUPER + R", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/minimalBar ipc call reminders toggle")) -- clipboard secondary
-- hide shell bar
bind("SUPER + SHIFT + SPACE", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/minimalBar ipc call bar toggle")) --hide bar
