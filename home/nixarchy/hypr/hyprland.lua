-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Intercept and mock package.loaded["default.hypr.monitor-workspaces"] before
-- require("default.hypr.omarchy") so Omarchy runs global workspaces (1-10) instead
-- of assigning separate 10-workspace blocks per monitor.
local function setup_global_workspaces()
	local M = { slots = 10 }

	function M.workspace_id(monitor, slot)
		return slot
	end

	local function action(fn, expression)
		if o and o.bind_expressions then
			o.bind_expressions[fn] = expression
		end
		return fn
	end

	function M.focus(slot, monitor_name)
		return action(function()
			hl.dispatch(hl.dsp.focus({ workspace = tostring(slot) }))
		end, "o.workspaces.focus(" .. slot .. ")")
	end

	function M.move_window(slot, follow)
		return action(function()
			hl.dispatch(hl.dsp.window.move({ workspace = tostring(slot), follow = follow ~= false }))
		end, "o.workspaces.move_window(" .. slot .. (follow == false and ", false" or "") .. ")")
	end

	function M.move_to_monitor(direction)
		return action(function()
			local target = hl.get_monitor(direction)
			if target then
				hl.dispatch(hl.dsp.workspace.move({ monitor = target.name }))
			end
		end, "o.workspaces.move_to_monitor(" .. string.format("%q", direction) .. ")")
	end

	function M.move_window_to_monitor(direction)
		return action(function()
			local target = hl.get_monitor(direction)
			if target then
				hl.dispatch(hl.dsp.window.move({ monitor = target.name }))
			end
		end, "o.workspaces.move_window_to_monitor(" .. string.format("%q", direction) .. ")")
	end

	-- No-op: Disable all auto-relocation / monitor isolation
	function M.reconcile() end

	-- Sync ~/.local/state/omarchy/monitor-workspaces so all monitors use block 0.
	-- This ensures omarchy-shell (Workspaces.qml) displays global workspaces 1-10 on all monitor bars.
	local function sync_bar_state()
		local state_dir = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/omarchy"
		local file = io.open(state_dir .. "/monitor-workspaces", "w")
		if file then
			for _, monitor in ipairs(hl.get_monitors()) do
				local desc = monitor.description or monitor.name
				file:write(string.format("0\t%s\t%s\n", monitor.name, desc))
			end
			file:close()
		end
	end

	hl.on("hyprland.start", sync_bar_state)
	hl.on("config.reloaded", sync_bar_state)
	hl.on("monitor.added", sync_bar_state)
	hl.on("monitor.removed", sync_bar_state)

	o.workspaces = M
	return M
end

package.loaded["default.hypr.monitor-workspaces"] = setup_global_workspaces()

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")
