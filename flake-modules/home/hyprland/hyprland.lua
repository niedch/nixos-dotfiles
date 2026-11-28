-- ~/.config/hypr/hyprland.lua
-- Hyprland configuration entrypoint

require("config.autostart")
require("config.monitors")
require("config.env")
require("config.looknfeel")
require("config.animations")
require("config.input")
require("config.rules")

-- Optional DMS modules (safely required in case DMS has not yet generated them)
local dms_modules = {
    "dms.colors",
    "dms.outputs",
    "dms.layout",
    "dms.cursor",
    "dms.input",
    "dms.binds",
    "dms.binds-user",
    "dms.windowrules",
}

for _, mod in ipairs(dms_modules) do
    pcall(require, mod)
end

require("config.keybindings")
