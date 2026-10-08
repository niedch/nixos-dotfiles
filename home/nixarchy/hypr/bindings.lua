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

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding Scrolling window mode
hl.unbind("SUPER + L")
hl.unbind("SUPER + J")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

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
hl.bind(mainMod .. " + j", hl.dsp.workspace.toggle_special("j-workspace"), { description = "Toggle J workspace" })
hl.bind(mainMod .. " + l", hl.dsp.workspace.toggle_special("l-workspace"), { description = "Toggle L workspace" })
hl.bind(mainMod .. " + s", hl.dsp.workspace.toggle_special("s-workspace"), { description = "Toggle S workspace" })
hl.bind("CTRL + ALT + j", hl.dsp.workspace.toggle_special("j-workspace"), { description = "Move to J workspace" })
hl.bind("CTRL + ALT + l", hl.dsp.workspace.toggle_special("l-workspace"), { description = "Move to L workspace" })
hl.bind("CTRL + ALT + s", hl.dsp.workspace.toggle_special("s-workspace"), { description = "Move to S workspace" })


-- Workspaces (Ctrl+Alt row)
local ctrl_alt_keys = { "q", "w", "e", "r", "t", "y", "u", "i", "o", "p" }
for i, key in ipairs(ctrl_alt_keys) do
	hl.bind("CTRL + ALT + " .. key,              hl.dsp.focus({ workspace = i }), { description = string.format("Focus workspace %d", i) })
	hl.bind("CTRL + ALT + SHIFT + " .. key,      hl.dsp.window.move({ workspace = i }), { description = string.format("Move to workspace %d", i) })
end

-- Cycle the active workspace to the next monitor.
-- SUPER+TAB was "Next workspace"; CTRL+ALT+TAB was "Focus on next monitor".
hl.unbind("SUPER + TAB")
hl.unbind("CTRL + ALT + TAB")
o.bind("SUPER + TAB", "Cycle workspace to next monitor", "$HOME/.config/hypr/cycle-workspace-monitor.sh")
o.bind("CTRL + ALT + TAB", "Cycle workspace to next monitor", "$HOME/.config/hypr/cycle-workspace-monitor.sh")
