-------------------
--- My Programs ---
-------------------

BROWSER = "helium-browser"
FILEMANAGER = "nautilus"
MENU = "pkill -x rofi || rofi -show drun -theme ~/.config/rofi/config.rasi"
TERMINAL = "ghostty"

---------------------
--- Env Variables ---
---------------------

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")

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
