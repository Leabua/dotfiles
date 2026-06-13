--------------
--- INPUTS ---
--------------

hl.config({
	input = {
		kb_layout = "us",
		kb_options = "caps:swapescape",

		repeat_rate = 60,
		repeat_delay = 300,

		numlock_by_default = true,

		follow_mouse = 1,
		touchpad = {
			natural_scroll = true,
			scroll_factor = 1,
		},
	},
	cursor = {
		hide_on_key_press = true,
		inactive_timeout = 10,
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
