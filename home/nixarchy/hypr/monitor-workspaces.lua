-- Global workspaces 1-10 replacement for Omarchy's per-monitor workspaces.
-- Keeps workspaces numbered 1-10 globally across all displays, while maintaining
-- full compatibility with the Omarchy shell bar widget and keybinding dispatchers.

local paths = require("default.hypr.paths")

local SLOTS = 10
local STATE_DIR = paths.state_home .. "/omarchy"
local STATE_FILE = STATE_DIR .. "/monitor-workspaces"

local M = {
  slots = SLOTS,
  enabled = false,
}

o = o or {}
o.bind_expressions = o.bind_expressions or {}

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function action(fn, expression)
  o.bind_expressions[fn] = expression
  return fn
end

local function literal(value)
  if value == nil then
    return "nil"
  end
  return string.format("%q", value)
end

local function target_monitor(name)
  if name then
    return hl.get_monitor(name)
  end
  return hl.get_active_monitor()
end

-- Connected monitors that are not mirrors.
local function connected(gone)
  local monitors = {}
  for _, monitor in ipairs(hl.get_monitors()) do
    if not monitor.is_mirror and monitor.name ~= gone then
      monitors[#monitors + 1] = monitor
    end
  end

  table.sort(monitors, function(left, right)
    return (left.id or 0) < (right.id or 0)
  end)

  return monitors
end

-- Slot maps 1:1 to workspace ID.
function M.workspace_id(monitor, slot)
  return slot
end

-- Focus slot directly on target monitor or active monitor.
function M.focus(slot, monitor_name)
  return action(function()
    local monitor = target_monitor(monitor_name)
    if not monitor then
      return
    end

    if not monitor.focused then
      hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
    end

    hl.dispatch(hl.dsp.focus({ workspace = tostring(slot) }))
  end, "o.workspaces.focus(" .. slot .. (monitor_name and ", " .. literal(monitor_name) or "") .. ")")
end

-- Move active window to slot.
function M.move_window(slot, follow)
  return action(function()
    local window = hl.get_active_window()
    if not window then
      return
    end

    hl.dispatch(hl.dsp.window.move({
      workspace = tostring(slot),
      follow = follow ~= false,
      window = "address:" .. window.address,
    }))
  end, "o.workspaces.move_window(" .. slot .. (follow == false and ", false" or "") .. ")")
end

-- Move active workspace to target monitor without changing workspace IDs.
function M.move_to_monitor(direction)
  return action(function()
    local workspace = hl.get_active_workspace()
    if not workspace or workspace.special or workspace.id <= 0 then
      return
    end

    local target = hl.get_monitor(direction)
    local monitor = target and target.name or (type(direction) == "string" and direction or nil)
    if not monitor then
      return
    end

    hl.dispatch(hl.dsp.workspace.move({ monitor = monitor }))
    hl.dispatch(hl.dsp.focus({ workspace = tostring(workspace.id) }))
  end, "o.workspaces.move_to_monitor(" .. literal(direction) .. ")")
end

-- Move active window to target monitor.
function M.move_window_to_monitor(direction)
  return action(function()
    local target = hl.get_monitor(direction)
    local monitor = target and target.name or (type(direction) == "string" and direction or nil)
    if monitor then
      hl.dispatch(hl.dsp.window.move({ monitor = monitor }))
    end
  end, "o.workspaces.move_window_to_monitor(" .. literal(direction) .. ")")
end

-- State caching to avoid redundant filesystem writes.
local written = nil

local function save(lines)
  local content = table.concat(lines, "\n") .. "\n"
  if content == written then
    return
  end

  local file = io.open(STATE_FILE, "w")
  if not file then
    os.execute("mkdir -p " .. (o.shell_quote or shell_quote)(STATE_DIR))
    file = io.open(STATE_FILE, "w")
  end

  if file then
    file:write(content)
    file:close()
    written = content
  end
end

-- Reconcile: Assigns block 0 to every connected monitor so the Omarchy shell
-- bar widget displays workspaces 1-10 on all displays.
function M.reconcile(added, gone)
  local monitors = connected(gone)
  if #monitors == 0 then
    return
  end

  local lines = {}
  for _, monitor in ipairs(monitors) do
    local connector = monitor.name or ""
    local description = monitor.description or ""
    local identity = description ~= "" and description or connector
    if connector ~= "" then
      lines[#lines + 1] = "0\t" .. connector .. "\t" .. identity
    end
  end

  save(lines)
end

-- Event listeners.
hl.on("hyprland.start", function()
  M.reconcile()
end)

hl.on("config.reloaded", function()
  M.reconcile()
end)

hl.on("monitor.added", function(monitor)
  M.reconcile(monitor and monitor.name)
end)

hl.on("monitor.removed", function(monitor)
  M.reconcile(nil, monitor and monitor.name)
end)

-- Reconcile immediately upon loading.
M.reconcile()

-- Register globally and prevent upstream per-monitor workspace module from taking over.
package.loaded["default.hypr.monitor-workspaces"] = M
o.workspaces = M

return M
