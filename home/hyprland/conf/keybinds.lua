-- Applications
hl.bind(mainMod .. " + Return",        hl.dsp.exec_cmd(terminal), { description = "Open terminal" })
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("xdg-open ~"), { description = "Open file manager" })
hl.bind(mainMod .. " + SHIFT + F",     hl.dsp.window.float({ action = "toggle" }), { description = "Toggle float" })
hl.bind(mainMod .. " + SHIFT + N",     hl.dsp.exec_cmd(terminal .. " -e nvim"), { description = "Open Neovim" })
hl.bind(mainMod .. " + SHIFT + T",     hl.dsp.exec_cmd("theme-switcher"), { description = "Switch theme" })
hl.bind(mainMod .. " + SHIFT + B",     hl.dsp.exec_cmd("theme-wallpaper"), { description = "Switch wallpaper" })
hl.bind(mainMod .. " + Space",         hl.dsp.exec_cmd(launcher .. " toggle"), { description = "Application launcher" })
hl.bind(mainMod .. " + ALT + Space",   hl.dsp.exec_cmd(menu .. " toggle"), { description = "System menu" })
hl.bind(mainMod .. " + CTRL + E",      hl.dsp.exec_cmd(launcher .. " symbols"), { description = "Emoji picker" })
hl.bind(mainMod .. " + CTRL + V",      hl.dsp.exec_cmd(launcher .. " clipboard"), { description = "Clipboard history" })
hl.bind(mainMod .. " + CTRL + C",      hl.dsp.exec_cmd("quickshell-shell toggle quickshell.clipboard"), { locked = true, description = "Clipboard manager" })
hl.bind(mainMod .. " + N",             hl.dsp.exec_cmd("quickshell ipc call nic.numi toggle"), { locked = true, description = "Numi calculator" })
hl.bind(mainMod .. " + CTRL + R",      hl.dsp.exec_cmd("omarchy-reminder -i"), { locked = true, description = "Set reminder" })

-- Universal copy/paste/cut
hl.bind(mainMod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }), { description = "Copy (send Ctrl+Insert)" })
hl.bind(mainMod .. " + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }), { description = "Paste (send Shift+Insert)" })
hl.bind(mainMod .. " + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X" }), { description = "Cut (send Ctrl+X)" })

-- Window management
hl.bind(mainMod .. " + W",             hl.dsp.window.close(), { description = "Close window" })
hl.bind(mainMod .. " + M",             hl.dsp.exit(), { description = "Exit Hyprland" })
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen(), { description = "Toggle fullscreen" })
hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo(), { description = "Toggle pseudo tiling" })

-- Focus movement
hl.bind(mainMod .. " + left",          hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(mainMod .. " + right",         hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(mainMod .. " + up",            hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(mainMod .. " + down",          hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

-- Workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key,          hl.dsp.focus({ workspace = i }), { description = string.format("Focus workspace %d", i) })
	hl.bind(mainMod .. " + SHIFT + " .. key,  hl.dsp.window.move({ workspace = i }), { description = string.format("Move to workspace %d", i) })
end

-- Workspaces (Ctrl+Alt row)
local ctrl_alt_keys = { "q", "w", "e", "r", "t", "y", "u", "i", "o", "p" }
for i, key in ipairs(ctrl_alt_keys) do
	hl.bind("CTRL + ALT + " .. key,              hl.dsp.focus({ workspace = i }), { description = string.format("Focus workspace %d", i) })
	hl.bind("CTRL + ALT + SHIFT + " .. key,      hl.dsp.window.move({ workspace = i }), { description = string.format("Move to workspace %d", i) })
end

-- Special workspaces
hl.bind(mainMod .. " + j", hl.dsp.workspace.toggle_special("j-workspace"), { description = "Toggle J workspace" })
hl.bind(mainMod .. " + l", hl.dsp.workspace.toggle_special("l-workspace"), { description = "Toggle L workspace" })
hl.bind(mainMod .. " + s", hl.dsp.workspace.toggle_special("s-workspace"), { description = "Toggle S workspace" })
hl.bind("CTRL + ALT + j", hl.dsp.workspace.toggle_special("j-workspace"), { description = "Move to J workspace" })
hl.bind("CTRL + ALT + l", hl.dsp.workspace.toggle_special("l-workspace"), { description = "Move to L workspace" })
hl.bind("CTRL + ALT + s", hl.dsp.workspace.toggle_special("s-workspace"), { description = "Move to S workspace" })

-- Move workspace to monitor
hl.bind(mainMod .. " + TAB",           hl.dsp.exec_cmd("~/.config/hypr/cycle-workspace-monitor.sh"), { description = "Next workspace on monitor" })
hl.bind("CTRL + ALT + TAB",            hl.dsp.exec_cmd("~/.config/hypr/cycle-workspace-monitor.sh"), { description = "Next workspace on monitor" })
hl.bind(mainMod .. " + SHIFT + ALT + left",  hl.dsp.workspace.move({ monitor = "l" }), { description = "Move workspace to left monitor" })
hl.bind(mainMod .. " + SHIFT + ALT + right", hl.dsp.workspace.move({ monitor = "r" }), { description = "Move workspace to right monitor" })
hl.bind(mainMod .. " + SHIFT + ALT + up",    hl.dsp.workspace.move({ monitor = "u" }), { description = "Move workspace to monitor above" })
hl.bind(mainMod .. " + SHIFT + ALT + down",  hl.dsp.workspace.move({ monitor = "d" }), { description = "Move workspace to monitor below" })

-- Swap windows
hl.bind(mainMod .. " + SHIFT + h",     hl.dsp.window.swap({ direction = "l" }), { description = "Swap window left" })
hl.bind(mainMod .. " + SHIFT + l",     hl.dsp.window.swap({ direction = "r" }), { description = "Swap window right" })
hl.bind(mainMod .. " + SHIFT + k",     hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
hl.bind(mainMod .. " + SHIFT + j",     hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "l" }), { description = "Swap window left" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }), { description = "Swap window right" })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })

-- Cycle windows
hl.bind("ALT + TAB",                   hl.dsp.window.cycle_next(), { description = "Cycle to next window" })
hl.bind("ALT + SHIFT + TAB",           hl.dsp.window.cycle_next({ next = false }), { description = "Cycle to previous window" })
hl.bind("ALT + TAB",                   hl.dsp.window.bring_to_top(), { description = "Bring window to top" })

-- Resize windows
hl.bind(mainMod .. " + minus",             hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { description = "Shrink width" })
hl.bind(mainMod .. " + equal",             hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { description = "Grow width" })
hl.bind(mainMod .. " + SHIFT + minus",     hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { description = "Shrink height" })
hl.bind(mainMod .. " + SHIFT + equal",     hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { description = "Grow height" })

-- Mouse
hl.bind(mainMod .. " + mouse:272",     hl.dsp.window.drag(),   { mouse = true, description = "Drag window" })
hl.bind(mainMod .. " + mouse:273",     hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

-- Groups
hl.bind(mainMod .. " + G",             hl.dsp.group.toggle(), { description = "Toggle group" })
hl.bind(mainMod .. " + ALT + G",       hl.dsp.window.move({ out_of_group = true }), { description = "Remove from group" })

hl.bind(mainMod .. " + ALT + h",       hl.dsp.group.move_window({ direction = "l" }), { description = "Move window in group" })
hl.bind(mainMod .. " + ALT + l",       hl.dsp.group.move_window({ direction = "r" }), { description = "Move window in group" })
hl.bind(mainMod .. " + ALT + k",       hl.dsp.group.move_window({ direction = "u" }), { description = "Move window in group" })
hl.bind(mainMod .. " + ALT + j",       hl.dsp.group.move_window({ direction = "d" }), { description = "Move window in group" })
hl.bind(mainMod .. " + ALT + left",    hl.dsp.group.move_window({ direction = "l" }), { description = "Move window in group" })
hl.bind(mainMod .. " + ALT + right",   hl.dsp.group.move_window({ direction = "r" }), { description = "Move window in group" })
hl.bind(mainMod .. " + ALT + up",      hl.dsp.group.move_window({ direction = "u" }), { description = "Move window in group" })
hl.bind(mainMod .. " + ALT + down",    hl.dsp.group.move_window({ direction = "d" }), { description = "Move window in group" })

hl.bind(mainMod .. " + ALT + TAB",     hl.dsp.group.next(), { description = "Cycle to next group" })
hl.bind(mainMod .. " + ALT + SHIFT + TAB", hl.dsp.group.prev(), { description = "Cycle to previous group" })
hl.bind(mainMod .. " + ALT + mouse_down",  hl.dsp.group.next(), { description = "Cycle to next group" })
hl.bind(mainMod .. " + ALT + mouse_up",    hl.dsp.group.prev(), { description = "Cycle to previous group" })

hl.bind(mainMod .. " + CTRL + h",      hl.dsp.group.prev(), { description = "Previous group" })
hl.bind(mainMod .. " + CTRL + l",      hl.dsp.group.next(), { description = "Next group" })

for i = 1, 5 do
	hl.bind(mainMod .. " + ALT + " .. i, hl.dsp.group.active({ index = i }), { description = string.format("Switch to group %d", i) })
end

-- Notifications
hl.bind(mainMod .. " + COMMA",         hl.dsp.exec_cmd("quickshell-notif toggle"), { description = "Notification center" })
hl.bind(mainMod .. " + SHIFT + COMMA", hl.dsp.exec_cmd("quickshell-notif clear"), { description = "Clear notifications" })

-- Capture menu and color picker
hl.bind("Print",                       hl.dsp.exec_cmd(menu .. " toggle"), { description = "Quick menu" })
hl.bind(mainMod .. " + Print",         hl.dsp.exec_cmd("pkill hyprpicker; hyprpicker -a"), { description = "Color picker" })

-- Lock screen
hl.bind(mainMod .. " + CTRL + L",     hl.dsp.exec_cmd("hyprlock"), { description = "Lock screen" })

-- Blue light filter toggle
hl.bind(mainMod .. " + ALT + N",  hl.dsp.exec_cmd("~/.config/hypr/toggle-sunset.sh"), { description = "Toggle night light" })

-- System monitor
hl.bind(mainMod .. " + CTRL + T",     hl.dsp.exec_cmd(terminal .. " -e btop"), { description = "System monitor (btop)" })

-- Volume
hl.bind("XF86AudioRaiseVolume",        hl.dsp.exec_cmd("qs-volume up"),                                        { locked = true, repeating = true, description = "Raise volume" })
hl.bind("XF86AudioLowerVolume",        hl.dsp.exec_cmd("qs-volume down"),                                      { locked = true, repeating = true, description = "Lower volume" })
hl.bind("XF86AudioMute",               hl.dsp.exec_cmd("qs-volume mute"),                                     { locked = true, description = "Toggle mute" })
hl.bind("XF86AudioMicMute",            hl.dsp.exec_cmd("qs-volume micmute"),                                  { locked = true, description = "Toggle mic mute" })

-- Brightness
hl.bind("XF86MonBrightnessUp",         hl.dsp.exec_cmd("omarchy-brightness-display +5%"),                      { locked = true, repeating = true, description = "Brightness up" })
hl.bind("XF86MonBrightnessDown",       hl.dsp.exec_cmd("omarchy-brightness-display 5%-"),                      { locked = true, repeating = true, description = "Brightness down" })
hl.bind("SHIFT + XF86MonBrightnessUp",   hl.dsp.exec_cmd("omarchy-brightness-display 100%"),                   { locked = true, description = "Brightness max" })
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("omarchy-brightness-display 1%"),                     { locked = true, description = "Brightness min" })

-- Media
hl.bind("XF86AudioNext",               hl.dsp.exec_cmd("playerctl next"),                                 { locked = true, description = "Next track" })
hl.bind("XF86AudioPause",              hl.dsp.exec_cmd("playerctl play-pause"),                            { locked = true, description = "Play / Pause" })
hl.bind("XF86AudioPlay",               hl.dsp.exec_cmd("playerctl play-pause"),                            { locked = true, description = "Play / Pause" })
hl.bind("XF86AudioPrev",               hl.dsp.exec_cmd("playerctl previous"),                              { locked = true, description = "Previous track" })
