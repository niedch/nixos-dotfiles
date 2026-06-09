local theme_file = os.getenv("HOME") .. "/.config/hypr/theme.lua"
local f = io.open(theme_file, "r")
if f then
	f:close()
	dofile(theme_file)
end

local mainMod = "SUPER"
local terminal = "ghostty"
local fileManager = "nautilus"
local menu = "omarchy-launch-walker"

hl.on("hyprland.start", function()
	hl.exec_cmd("elephant")
	hl.exec_cmd("walker --gapplication-service")
	hl.exec_cmd("waybar")
	hl.exec_cmd("mako")
	hl.exec_cmd("hypridle")
end)

hl.monitor({
	output   = "",
	mode     = "1920x1080@60",
	position = "auto",
	scale    = 1,
})

hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.config({
	general = {
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		active_opacity = 0.97,
		inactive_opacity = 0.9,
		blur = {
			enabled = true,
			size = 2,
			passes = 2,
			special = true,
			brightness = 0.60,
			contrast = 0.75,
		},
	},
	group = {
		col = {
			border_locked_active = "rgba(33ccffee)",
			border_locked_inactive = "rgba(595959aa)",
		},
		groupbar = {
			font_size = 12,
			font_family = "monospace",
			font_weight_active = "ultraheavy",
			font_weight_inactive = "normal",
			indicator_height = 0,
			indicator_gap = 5,
			height = 22,
			gaps_in = 5,
			gaps_out = 0,
			text_color = "rgb(ffffff)",
			text_color_inactive = "rgba(ffffff90)",
			col = {
				active = "rgba(00000040)",
				inactive = "rgba(00000020)",
			},
			gradients = true,
			gradient_rounding = 0,
		},
	},
	dwindle = {
		preserve_split = true,
		force_split = 2,
	},
	master = {
		new_status = "master",
	},
	scrolling = {
		column_width = 0.49,
	},
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		disable_scale_notification = true,
		focus_on_activate = true,
		anr_missed_pings = 3,
		on_focus_under_fullscreen = 1,
	},
	cursor = {
		hide_on_key_press = true,
		warp_on_change_workspace = 1,
	},
	binds = {
		hide_special_on_workspace_change = true,
	},
	input = {
		kb_layout = "us",
		kb_options = "compose:caps",
		repeat_rate = 40,
		repeat_delay = 600,
		sensitivity = -0.5,
		follow_mouse = 1,
		numlock_by_default = false,
		touchpad = {
			natural_scroll = true,
		},
	},
})


hl.window_rule({
	name  = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name  = "fix-xwayland-drags",
	match = {
		class      = "^$",
		title      = "^$",
		xwayland   = true,
		float      = true,
		fullscreen = false,
		pin        = false,
	},
	no_focus = true,
})

hl.window_rule({
	name  = "chromium-opacity",
	match = { class = "chromium" },
	opacity = 0.95,
})

hl.window_rule({
	name  = "youtube-opacity",
	match = { class = "chrome-www.youtube.com__-Default" },
	opacity = 0.9,
})

hl.layer_rule({ rule = "no_anim", match = "namespace:walker" })
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0, border_size = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_in = 0, gaps_out = 0, border_size = 0 })

-- Applications
hl.bind(mainMod .. " + Return",        hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd("xdg-open ~"))
hl.bind(mainMod .. " + SHIFT + F",     hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + N",     hl.dsp.exec_cmd(terminal .. " -e nvim"))
hl.bind(mainMod .. " + Space",         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + CTRL + E",      hl.dsp.exec_cmd(menu .. " -m symbols"))
hl.bind(mainMod .. " + CTRL + V",      hl.dsp.exec_cmd(menu .. " -m clipboard"))

-- Window management
hl.bind(mainMod .. " + Q",             hl.dsp.window.close())
hl.bind(mainMod .. " + M",             hl.dsp.exec_cmd("hyprctl dispatch exit"))
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo())

-- Focus movement
hl.bind(mainMod .. " + h",             hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l",             hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k",             hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j",             hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + left",          hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right",         hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",            hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",          hl.dsp.focus({ direction = "down" }))

-- Workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key,          hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key,  hl.dsp.window.move({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + ALT + " .. key, hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent " .. i))
end

-- Scratchpad
hl.bind(mainMod .. " + S",             hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mainMod .. " + ALT + S",       hl.dsp.exec_cmd("hyprctl dispatch movetoworkspacesilent special:scratchpad"))

-- Workspace navigation
hl.bind(mainMod .. " + mouse_down",    hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",      hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + TAB",           hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + SHIFT + TAB",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + TAB",    hl.dsp.exec_cmd("hyprctl dispatch workspace previous"))

-- Swap windows
hl.bind(mainMod .. " + SHIFT + h",     hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l",     hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k",     hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j",     hl.dsp.window.swap({ direction = "d" }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "d" }))

-- Move workspace to monitor
hl.bind(mainMod .. " + SHIFT + ALT + left",  hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor l"))
hl.bind(mainMod .. " + SHIFT + ALT + right", hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor r"))
hl.bind(mainMod .. " + SHIFT + ALT + up",    hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor u"))
hl.bind(mainMod .. " + SHIFT + ALT + down",  hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor d"))

-- Cycle windows
hl.bind("ALT + TAB",                   hl.dsp.exec_cmd("hyprctl dispatch cyclenext"))
hl.bind("ALT + SHIFT + TAB",           hl.dsp.exec_cmd("hyprctl dispatch cyclenext prev"))
hl.bind("ALT + TAB",                   hl.dsp.window.bring_to_top())

-- Resize windows
	hl.bind(mainMod .. " + minus",             hl.dsp.exec_cmd("hyprctl dispatch resizeactive -100 0"))
	hl.bind(mainMod .. " + equal",             hl.dsp.exec_cmd("hyprctl dispatch resizeactive 100 0"))
	hl.bind(mainMod .. " + SHIFT + minus",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -100"))
	hl.bind(mainMod .. " + SHIFT + equal",     hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 100"))

-- Mouse
hl.bind(mainMod .. " + mouse:272",     hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",     hl.dsp.window.resize(), { mouse = true })

-- Groups
hl.bind(mainMod .. " + G",             hl.dsp.group.toggle())
hl.bind(mainMod .. " + ALT + G",       hl.dsp.exec_cmd("hyprctl dispatch moveoutofgroup"))

hl.bind(mainMod .. " + ALT + h",       hl.dsp.group.move_window({ direction = "l" }))
hl.bind(mainMod .. " + ALT + l",       hl.dsp.group.move_window({ direction = "r" }))
hl.bind(mainMod .. " + ALT + k",       hl.dsp.group.move_window({ direction = "u" }))
hl.bind(mainMod .. " + ALT + j",       hl.dsp.group.move_window({ direction = "d" }))
hl.bind(mainMod .. " + ALT + left",    hl.dsp.group.move_window({ direction = "l" }))
hl.bind(mainMod .. " + ALT + right",   hl.dsp.group.move_window({ direction = "r" }))
hl.bind(mainMod .. " + ALT + up",      hl.dsp.group.move_window({ direction = "u" }))
hl.bind(mainMod .. " + ALT + down",    hl.dsp.group.move_window({ direction = "d" }))

hl.bind(mainMod .. " + ALT + TAB",     hl.dsp.group.next())
hl.bind(mainMod .. " + ALT + SHIFT + TAB", hl.dsp.group.prev())
hl.bind(mainMod .. " + ALT + mouse_down",  hl.dsp.group.next())
hl.bind(mainMod .. " + ALT + mouse_up",    hl.dsp.group.prev())

hl.bind(mainMod .. " + CTRL + h",      hl.dsp.group.prev())
hl.bind(mainMod .. " + CTRL + l",      hl.dsp.group.next())

for i = 1, 5 do
	hl.bind(mainMod .. " + ALT + " .. i, hl.dsp.exec_cmd("hyprctl dispatch changegroupactive " .. i))
end

-- Notifications
hl.bind(mainMod .. " + COMMA",         hl.dsp.exec_cmd("makoctl dismiss"))
hl.bind(mainMod .. " + SHIFT + COMMA", hl.dsp.exec_cmd("makoctl dismiss --all"))

-- Screenshots and color picker
hl.bind("Print",                       hl.dsp.exec_cmd("grim -g \"$(slurp)\""))
hl.bind(mainMod .. " + Print",         hl.dsp.exec_cmd("pkill hyprpicker; hyprpicker -a"))

-- Lock screen
hl.bind(mainMod .. " + CTRL + L",     hl.dsp.exec_cmd("hyprlock"))

-- System monitor
hl.bind(mainMod .. " + CTRL + T",     hl.dsp.exec_cmd(terminal .. " -e btop"))

-- Volume
hl.bind("XF86AudioRaiseVolume",        hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",        hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",               hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",            hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",         hl.dsp.exec_cmd("brightnessctl set 5%+"),                           { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",       hl.dsp.exec_cmd("brightnessctl set 5%-"),                           { locked = true, repeating = true })
hl.bind("SHIFT + XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 100%"),                        { locked = true })
hl.bind("SHIFT + XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 1%"),                          { locked = true })

-- Media
hl.bind("XF86AudioNext",               hl.dsp.exec_cmd("playerctl next"),                                 { locked = true })
hl.bind("XF86AudioPause",              hl.dsp.exec_cmd("playerctl play-pause"),                            { locked = true })
hl.bind("XF86AudioPlay",               hl.dsp.exec_cmd("playerctl play-pause"),                            { locked = true })
hl.bind("XF86AudioPrev",               hl.dsp.exec_cmd("playerctl previous"),                              { locked = true })
