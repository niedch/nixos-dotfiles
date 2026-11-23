local mainMod     = "SUPER"
local ipc         = "dms ipc call "
local terminal    = "ghostty"
local fileManager = "nautilus"

-- Apps & Window Management
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + W",      hl.dsp.window.close())
hl.bind(mainMod .. " + M",      hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + L",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + C",         hl.dsp.send_shortcut({ mods = "CTRL", key = "c", window = "activewindow" }))
hl.bind(mainMod .. " + V",         hl.dsp.send_shortcut({ mods = "CTRL", key = "v", window = "activewindow" }))
hl.unbind("SUPER + F")
hl.bind(mainMod .. " + F", function()
    hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
end)

-- DMS IPC
hl.bind(mainMod .. " + Space",        hl.dsp.exec_cmd(ipc .. "spotlight toggle"))
hl.bind(mainMod .. " + S",            hl.dsp.exec_cmd(ipc .. "control-center toggle"))
hl.bind(mainMod .. " + comma",        hl.dsp.exec_cmd(ipc .. "settings focusOrToggle"))
hl.bind("ALT + Tab",                  hl.dsp.exec_cmd(ipc .. "hypr toggleOverview"))

-- Screenshots (DMS built-in)
hl.bind("Print",                      hl.dsp.exec_cmd("dms screenshot full"))
hl.bind(mainMod .. " + SHIFT + S",    hl.dsp.exec_cmd("dms screenshot"))

-- Lock screen & Session power menu
hl.bind(mainMod .. " + escape",        hl.dsp.exec_cmd(ipc .. "lock lock"))
hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.exec_cmd(ipc .. "lock lock"))
hl.bind(mainMod .. " + SHIFT + Q",     hl.dsp.exec_cmd(ipc .. "powermenu toggle"))

-- AI Mirror kill switch
hl.bind(mainMod .. " + SHIFT + escape", hl.dsp.exec_cmd("ai-mirror control off"))

-- Media & Brightness keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(ipc .. "audio increment 3"),     { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(ipc .. "audio decrement 3"),     { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(ipc .. "audio mute"),            { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(ipc .. 'brightness increment 5 ""'), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. 'brightness decrement 5 ""'), { locked = true, repeating = true })

-- Focus navigation (arrows & hjkl)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down" }))

-- Move window (arrows & hjkl)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,               hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,       hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Corne-keyboard workspace bindings (CTRL + ALT + Q/W/E/R/T/Y/U/I/O/P)
local corne_keys = { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" }
for i, key in ipairs(corne_keys) do
    hl.bind("CTRL + ALT + " .. key,                      hl.dsp.focus({ workspace = i }))
    hl.bind("CTRL + ALT + SHIFT + " .. key,              hl.dsp.window.move({ workspace = i }))
    hl.bind("CTRL + ALT + SHIFT + " .. mainMod .. " + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Workspace-to-monitor moves
hl.bind(mainMod .. " + Tab",                 hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind(mainMod .. " + SHIFT + Tab",         hl.dsp.workspace.move({ monitor = "-1" }))
hl.bind("CTRL + ALT + Tab",                  hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind("CTRL + ALT + SHIFT + Tab",          hl.dsp.workspace.move({ monitor = "-1" }))

-- Workspace history and mouse wheel cycling
hl.bind(mainMod .. " + CTRL + Tab",          hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + mouse_down",          hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",            hl.dsp.focus({ workspace = "e-1" }))

-- Special Workspaces (H & G)
hl.bind("CTRL + ALT + H",                    hl.dsp.workspace.toggle_special("h-workspace"))
hl.bind("CTRL + ALT + G",                    hl.dsp.workspace.toggle_special("g-workspace"))
hl.bind(mainMod .. " + G",                   hl.dsp.workspace.toggle_special("g-workspace"))
hl.bind("CTRL + ALT + SHIFT + H",            hl.dsp.window.move({ workspace = "special:h-workspace", follow = false }))
hl.bind("CTRL + ALT + SHIFT + G",            hl.dsp.window.move({ workspace = "special:g-workspace", follow = false }))

-- Mouse dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
