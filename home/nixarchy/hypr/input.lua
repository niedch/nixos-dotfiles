-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input

-- Global default (applies to any keyboard not matched below).
hl.config({
  input = {
    kb_layout = "us",
    kb_options = "compose:caps,shift:both_capslock_cancel",

    -- Change speed of keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 250,

    -- Start with numlock on by default.
    numlock_by_default = true,

    -- Increase sensitivity for mouse/trackpad (default: 0).
    sensitivity = 0.35,

    -- Turn off mouse acceleration (default: adaptive).
    accel_profile = "flat",

    touchpad = {
      -- Use natural (inverse) scrolling.
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner.
      clickfinger_behavior = true,

      -- Control the speed of your scrolling.
      scroll_factor = 0.4,

      -- Enable the touchpad while typing.
      disable_while_typing = false,

      -- Left-click-and-drag with three fingers.
      drag_3fg = 1,
    },
  },
})

-- Built-in laptop keyboard (Austrian QWERTZ).
hl.device({
  name = "at-translated-set-2-keyboard",
  kb_layout = "at",
})

-- Per-device layout for external keyboards.
-- Capture the exact device name with (one keyboard plugged in at a time):
--   hyprctl devices -j | jq -r '.keyboards[] | select(.name | test("keyboard")) | .name'
-- Note: names are matched exactly (spaces become "-"), and a single physical
-- keyboard may appear as several nodes (e.g. "-keyboard", "-system-control",
-- "-consumer-control") — duplicate the block for each node that sends keys.
--
-- hl.device({
--   name = "<device-name>",
--   kb_layout = "us",
--   kb_variant = "",                 -- e.g. "intl" for international
--   kb_options = "compose:caps",
-- })
--
-- hl.device({ name = "<device-name>-keyboard",       kb_layout = "us" })
-- hl.device({ name = "<device-name>-system-control", kb_layout = "us" })

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })

