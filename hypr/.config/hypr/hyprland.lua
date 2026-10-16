---------------------------
--- My Default Programs ---
---------------------------

-- These need to go before the source files otherwise they will not load
-- and if they dont load hyprland will fell broken

BROWSER = "zen-beta"
FILEMANAGER = "thunar"
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
