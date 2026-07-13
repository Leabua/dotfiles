---------------------------
--- My Default Programs ---
---------------------------

BROWSER = "zen-beta"
FILEMANAGER = "nautilus"
TERMINAL = "ghostty"

---------------------
--- Env Variables ---
---------------------

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("GTK_THEME", "Adwaita:dark")

--------------------
--- Source Files ---
--------------------

require("modules/autostart")
require("modules/bindings")
require("modules/inputs")
require("modules/looknfeel")
require("modules/monitors")
require("modules/tiling")
require("modules/utilities")
require("modules/windowrules")
