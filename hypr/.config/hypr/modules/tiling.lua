--------------------
--- tiling rules ---
--------------------

local bind = hl.bind

-- window management
bind("SUPER + W", hl.dsp.window.close())
bind("SUPER + O", hl.dsp.window.float({ action = "toggle" }))
bind("SUPER + F", hl.dsp.window.fullscreen())

-- focus
bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
bind("SUPER + J", hl.dsp.focus({ direction = "down" }))

-- swap windows
bind("SUPER + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
bind("SUPER + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))
bind("SUPER + SHIFT + K", hl.dsp.window.swap({ direction = "up" }))
bind("SUPER + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))

-- resize horizontal
bind("SUPER + code:20", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
bind("SUPER + code:21", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))

-- resize vertical
bind("SUPER + SHIFT + code:20", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
bind("SUPER + SHIFT + code:21", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- switch workspaces
for i = 1, 9 do
	bind("SUPER +" .. i, hl.dsp.focus({ workspace = i }))
	bind("SUPER + SHIFT +" .. i, hl.dsp.window.move({ workspace = i }))
	bind("SUPER + SHIFT + CTRL +" .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- floating display stuff
bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))
bind("SUPER + + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- special workspace (scrathpad)
bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- mouse
bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
