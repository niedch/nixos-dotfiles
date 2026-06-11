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
	name   = "gazelle",
	match  = { class = "org\\.omarchy\\.Gazelle" },
	float  = true,
	center = true,
	size   = { 800, 600 },
})

hl.window_rule({
	name   = "bluetui",
	match  = { class = "org\\.omarchy\\.Bluetui" },
	float  = true,
	center = true,
	size   = { 800, 600 },
})

hl.window_rule({
	name   = "btop",
	match  = { class = "org\\.omarchy\\.Btop" },
	float  = true,
	center = true,
	size   = { 800, 600 },
})

hl.window_rule({
	name   = "wiremix",
	match  = { class = "org\\.omarchy\\.Wiremix" },
	float  = true,
	center = true,
	size   = { 800, 600 },
})

hl.layer_rule({ no_anim = true, match = { namespace = "walker" } })
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0, border_size = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_in = 0, gaps_out = 0, border_size = 0 })
