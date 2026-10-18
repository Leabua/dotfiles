-------------------------------
--- monitors and workspaces ---
-------------------------------

hl.env("GDK_SCALE", "1")

hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = "HDMI-A-1",
	-- mode = "1920x1080@60",
	mode = "1920x1080@60",
	position = "1920x0",
	scale = 1,
})

--- I just like to have the muscle memory ---
local ws = hl.workspace_rule

ws({
	workspace = "1",
	monitor = "eDP-1",
})

ws({
	workspace = "2",
	monitor = "eDP-1",
})

ws({
	workspace = "3",
	monitor = "HDMI-A-1",
})

ws({
	workspace = "4",
	monitor = "HDMI-A-1",
})

ws({
	workspace = "5",
	monitor = "eDP-1",
})
