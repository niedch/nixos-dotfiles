-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Unbind conflicting keys and per-monitor workspace defaults
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
hl.unbind("SUPER + CTRL + TAB")
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")
hl.unbind("CTRL + ALT + TAB")
hl.unbind("CTRL + ALT + SHIFT + TAB")
hl.unbind("SUPER + SHIFT + SPACE")

-- nixarchy's own plugins (#766). The helper says so if one is turned off.
o.bind("SUPER + ALT + N", "Packages", "nixarchy-plugin nixarchy.pkg")
o.bind("SUPER + ALT + O", "Podman", "nixarchy-plugin nixarchy.podman")
o.bind("SUPER + ALT + P", "GitLab Pipelines", "nixarchy-plugin olafkfreund.gitlab-pipelines")
o.bind("SUPER + CTRL + ALT + P", "GitLab Pipelines keybindings", "python3 $HOME/.config/omarchy/plugins/olafkfreund.gitlab-pipelines/menu.py keys")
o.bind("SUPER + ALT + A", "GitHub Actions", "nixarchy-plugin olafkfreund.github-actions")
o.bind("SUPER + CTRL + ALT + A", "GitHub Actions keybindings", "python3 $HOME/.config/omarchy/plugins/olafkfreund.github-actions/menu.py keys")
o.bind("SUPER + ALT + H", "Herdr", "nixarchy-plugin nixarchy.herdr")
o.bind("SUPER + ALT + V", "MicroVMs", "nixarchy-plugin nixarchy.microvm")
o.bind("SUPER + ALT + D", "Distrobox", "nixarchy-plugin nixarchy.distrobox")
o.bind("SUPER + ALT + E", "Dev environments", "nixarchy-plugin nixarchy.devenv")
o.bind("SUPER + ALT + U", "Plugin browser", "nixarchy-plugin io.github.olafkfreund.nixarchy-plugin-browser")

-- ai-mirror's kill switch (#773): revoke agent control and release held keys.
o.bind("SUPER + SHIFT + ESCAPE", "ai-mirror: stop agent control", "ai-mirror control off")

-- Special workspaces
hl.unbind("SUPER + H")
hl.bind("SUPER + H", hl.dsp.workspace.toggle_special("h-workspace"), { description = "Toggle H workspace" })

hl.unbind("SUPER + G")
hl.bind("SUPER + G", hl.dsp.workspace.toggle_special("g-workspace"), { description = "Toggle G workspace" })

hl.bind("CTRL + ALT + H", hl.dsp.workspace.toggle_special("h-workspace"), { description = "Toggle H workspace" })
hl.bind("CTRL + ALT + G", hl.dsp.workspace.toggle_special("g-workspace"), { description = "Toggle G workspace" })

hl.bind("CTRL + ALT + SHIFT + H", hl.dsp.window.move({ workspace = "special:h-workspace", follow = false }), { description = "Move window to H workspace" })
hl.bind("CTRL + ALT + SHIFT + G", hl.dsp.window.move({ workspace = "special:g-workspace", follow = false }), { description = "Move window to G workspace" })

-- Classic global workspaces 1-10 cleanly
for workspace = 1, 10 do
	local key = "code:" .. tostring(workspace + 9)
	o.rebind("SUPER + " .. key, "Switch to workspace " .. workspace, o.workspaces.focus(workspace))
	o.rebind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, o.workspaces.move_window(workspace))
	o.rebind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. workspace, o.workspaces.move_window(workspace, false))
end

-- Corne-keyboard workspace bindings for Ctrl+Alt
local ctrl_alt_keys = { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" }
for i, key in ipairs(ctrl_alt_keys) do
	o.bind("CTRL + ALT + " .. key, string.format("Focus workspace %d", i), o.workspaces.focus(i))
	o.bind("CTRL + ALT + SHIFT + " .. key, string.format("Move to workspace %d", i), o.workspaces.move_window(i))
	o.bind("CTRL + ALT + SHIFT + SUPER + " .. key, string.format("Move silently to workspace %d", i), o.workspaces.move_window(i, false))
end

-- Workspace-to-monitor cycling
o.bind("SUPER + TAB", "Move workspace to next monitor", o.workspaces.move_to_monitor("+1"))
o.bind("SUPER + SHIFT + TAB", "Move workspace to previous monitor", o.workspaces.move_to_monitor("-1"))
o.bind("CTRL + ALT + TAB", "Move workspace to next monitor", o.workspaces.move_to_monitor("+1"))
o.bind("CTRL + ALT + SHIFT + TAB", "Move workspace to previous monitor", o.workspaces.move_to_monitor("-1"))

-- Global workspace cycling
o.bind("SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("SUPER + mouse_down", "Scroll active workspace forward", hl.dsp.focus({ workspace = "e+1" }))
o.bind("SUPER + mouse_up", "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }))
