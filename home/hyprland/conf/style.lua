hl.monitor({
	output   = "",
	mode     = "1920x1080@60",
	position = "auto",
	scale    = 1,
})

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
		sensitivity = -0.3,
		follow_mouse = 1,
		numlock_by_default = false,
		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.curve("slideEase", { type = "bezier", points = { {0.25, 0.1}, {0.25, 1.0} } })
hl.curve("fastSnap", { type = "bezier", points = { {0.05, 0.7}, {0.1, 1.0} } })

hl.animation({ leaf = "windows",        enabled = true, speed = 0.4, bezier = "fastSnap", style = "popin" })
hl.animation({ leaf = "windowsOut",     enabled = true, speed = 0.4, bezier = "fastSnap", style = "popin" })
hl.animation({ leaf = "fade",           enabled = true, speed = 0.3, bezier = "fastSnap" })
hl.animation({ leaf = "workspaces",     enabled = true, speed = 1, bezier = "fastSnap", style = "slide" })
hl.animation({ leaf = "border",         enabled = true, speed = 0.8, bezier = "fastSnap" })
hl.animation({ leaf = "specialWorkspace",   enabled = true, speed = 1, bezier = "slideEase", style = "slidefadevert" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 1, bezier = "slideEase", style = "slidefadevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1, bezier = "slideEase", style = "slidefadevert" })
