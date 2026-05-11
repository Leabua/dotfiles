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
  mode = "1920x1080@60",
  position = "0x-1080",
  scale = 1,
})

--- I just like to have the muscle memory ---
hl.workspace_rule({
  workspace = "1",
  monitor = "eDP-1"
})
hl.workspace_rule({
  workspace = "2",
  monitor = "eDP-1"
})
hl.workspace_rule({
  workspace = "5",
  monitor = "eDP-1"
})

hl.workspace_rule({
  workspace = "3",
  monitor = "HDMI-A-1"
})
hl.workspace_rule({
  workspace = "4",
  monitor = "HDMI-A-1"
})
