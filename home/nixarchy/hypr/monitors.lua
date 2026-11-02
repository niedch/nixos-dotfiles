-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local hostname = (function()
  local f = io.open("/etc/hostname", "r")
  if f then
    local h = f:read("*l")
    f:close()
    return h and h:gsub("%s+", "")
  end
  return os.getenv("HOSTNAME") or ""
end)()

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Middle monitor (anchor): iiyama PL2760Q
if hostname == "desktop" then
  hl.monitor({
    output   = "desc:iiyama Corporation PL2760Q 1154112201014",
    mode     = "2560x1440@143.86Hz",
    position = "0x0",
    scale    = omarchy_monitor_scale,
  })
else
  hl.monitor({
    output   = "desc:iiyama Corporation PL2760Q 1154112201014",
    mode     = "1920x1080@60Hz",
    position = "0x0",
    scale    = omarchy_monitor_scale,
  })
end

-- Left monitor: iiyama PL2760H (1080p @ 144Hz)
hl.monitor({
  output   = "desc:iiyama Corporation PL2760H 1164004201390",
  mode     = "1920x1080@143.98Hz",
  position = "auto-left",
  scale    = omarchy_monitor_scale,
})

-- Laptop display (far right when docked, standalone (0x0) when undocked): Sharp Corporation 0x149A
hl.monitor({
  output   = "desc:Sharp Corporation 0x149A",
  mode     = "preferred",
  position = "auto-right",
  scale    = omarchy_monitor_scale,
})
