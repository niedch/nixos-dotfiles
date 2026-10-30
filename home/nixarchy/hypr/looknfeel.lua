-- Change the default Omarchy look'n'feel.

-- Workaround: Upstream Nixarchy / Omarchy cursor fallback bug (Omarchy v4.5.0-rc2).
-- Omarchy's startup (e.g. startup-cursor.lua) attempts to set cursor "default" on boot
-- without standard NixOS icon search paths in XCURSOR_PATH or default aliases.
-- Explicitly export theme variables, search paths, and hyprcursor synchronization
-- so Hyprland and Wayland/XWayland applications can locate cursor assets.
--
-- Safe to remove once fixed upstream in Nixarchy/Omarchy.
--
-- To test if fixed upstream:
--   1. Comment out the cursor hl.env(...) and hl.config(...) blocks below (and
--      home.pointerCursor in home/nixarchy/theme.nix).
--   2. Reload Hyprland (`hyprctl reload`) or log out/in.
--   3. Run `hyprctl getcursor` and verify that the active theme is recognized
--      and `hyprctl setcursor default 24` resolves properly.
--   4. Check Nixarchy commit logs / updates for changes to `startup-cursor.lua`
--      handling cursor fallback paths on NixOS.
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_PATH", (os.getenv("HOME") or "") .. "/.local/share/icons:" .. (os.getenv("HOME") or "") .. "/.icons:/run/current-system/sw/share/icons")

hl.config({
  cursor = {
    enable_hyprcursor = true,
    sync_gsettings_theme = true,
  },
})

hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0, border_size = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_in = 0, gaps_out = 0, border_size = 0 })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- Prime Video web app: keep fully opaque (no transparency).
o.window("^chrome-www\\.amazon\\.de__gp_video_storefront-Default$", { tag = "-default-opacity", opacity = "1 1" })
o.window("^chrome-www\\.twitch\\.-Default$", { tag = "-default-opacity", opacity = "1 1" })

-- Special workspace clients: keep fully opaque (no transparency).
o.window({ workspace = "s[true]" }, { tag = "-default-opacity", opacity = "1 1" })

-- Enable global blur in Hyprland
hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 3,
      passes = 2,
    },
  },
})

-- -- Enable blur for the Omarchy status bar
-- hl.layer_rule({
--   match = { namespace = "^omarchy-bar$" },
--   blur = true,
--   ignore_alpha = 0.2,
-- })
