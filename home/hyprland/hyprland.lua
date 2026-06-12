local theme_file = os.getenv("HOME") .. "/.config/hypr/theme.lua"
local f = io.open(theme_file, "r")
if f then
	f:close()
	dofile(theme_file)
end

mainMod = "SUPER"
terminal = "ghostty"
fileManager = "nautilus"
menu = "omarchy-launch-walker"

local conf_dir = os.getenv("HOME") .. "/.config/hypr/conf"
dofile(conf_dir .. "/env.lua")
dofile(conf_dir .. "/exec-once.lua")
dofile(conf_dir .. "/style.lua")
dofile(conf_dir .. "/windows.lua")
dofile(conf_dir .. "/keybinds.lua")
dofile(conf_dir .. "/keyboard.lua")
