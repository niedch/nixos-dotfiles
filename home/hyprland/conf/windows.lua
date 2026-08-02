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
	name  = "zen-opacity",
	match = { class = "zen-beta" },
	opacity = 0.95,
})

hl.window_rule({
	name  = "youtube-opacity",
	match = { class = "chrome-www.youtube.com__-Default" },
	opacity = 0.9,
})

hl.window_rule({
	name   = "tui-apps",
	match  = { class = "org\\.tui\\..*" },
	float  = true,
	center = true,
	size   = { 800, 600 },
})

hl.window_rule({
	name   = "steam-float",
	match  = { class = "steam" },
	float  = true,
})

hl.window_rule({
    name   = "calendar",
    match  = { class = "chrome-calendar\\.google\\.com__calendar_u_0_r_day_.*" },
    float  = true,
    center = true,
    size   = { 1000, 750 },
})

hl.layer_rule({ no_anim = true, match = { namespace = "walker" } })
hl.layer_rule({ no_anim = true, match = { namespace = "quickshell-launcher" } })
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0, border_size = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_in = 0, gaps_out = 0, border_size = 0 })
