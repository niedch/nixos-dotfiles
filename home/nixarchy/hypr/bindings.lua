local mainMod = "SUPER"

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

-- Unbind conflicting keys
hl.unbind("SUPER + J")
hl.unbind("SUPER + L")
hl.unbind("SUPER + S")
hl.unbind("SUPER + TAB")
hl.unbind("CTRL + ALT + TAB")

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
hl.bind("SUPER + J", hl.dsp.workspace.toggle_special("j-workspace"), { description = "Toggle J workspace" })
hl.bind("SUPER + L", hl.dsp.workspace.toggle_special("l-workspace"), { description = "Toggle L workspace" })
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("s-workspace"), { description = "Toggle S workspace" })

hl.bind("CTRL + ALT + J", hl.dsp.workspace.toggle_special("j-workspace"), { description = "Toggle J workspace" })
hl.bind("CTRL + ALT + L", hl.dsp.workspace.toggle_special("l-workspace"), { description = "Toggle L workspace" })
hl.bind("CTRL + ALT + S", hl.dsp.workspace.toggle_special("s-workspace"), { description = "Toggle S workspace" })

hl.bind("CTRL + ALT + SHIFT + J", hl.dsp.window.move({ workspace = "special:j-workspace", follow = false }), { description = "Move window to J workspace" })
hl.bind("CTRL + ALT + SHIFT + L", hl.dsp.window.move({ workspace = "special:l-workspace", follow = false }), { description = "Move window to L workspace" })
hl.bind("CTRL + ALT + SHIFT + S", hl.dsp.window.move({ workspace = "special:s-workspace", follow = false }), { description = "Move window to S workspace" })

-- Classic global workspaces 1-10 cleanly
for workspace = 1, 10 do
	local key = "code:" .. tostring(workspace + 9)
	o.rebind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
	o.rebind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
	o.rebind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false }))
end

-- Corne-keyboard workspace bindings for Ctrl+Alt
local ctrl_alt_keys = { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" }
for i, key in ipairs(ctrl_alt_keys) do
	hl.bind("CTRL + ALT + " .. key,              hl.dsp.focus({ workspace = tostring(i) }), { description = string.format("Focus workspace %d", i) })
	hl.bind("CTRL + ALT + SHIFT + " .. key,      hl.dsp.window.move({ workspace = tostring(i) }), { description = string.format("Move to workspace %d", i) })
end

-- Cycle workspace to next monitor (native Hyprland dispatcher, no external script or jq needed)
hl.bind("SUPER + TAB",      hl.dsp.workspace.move({ monitor = "+1" }), { description = "Cycle workspace to next monitor" })
hl.bind("CTRL + ALT + TAB", hl.dsp.workspace.move({ monitor = "+1" }), { description = "Cycle workspace to next monitor" })
