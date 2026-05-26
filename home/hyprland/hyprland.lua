local mainMod = "SUPER"

hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("dunst")
end)

hl.monitor({
	output   = "",
	mode     = "preferred",
	position = "auto",
	scale    = 1,
})

hl.env("XCURSOR_SIZE", "12")
hl.env("QT_QPA_PLATFORM", "wayland")

hl.config({
	input = {
		kb_layout    = "us",
		follow_mouse = 1,
		sensitivity  = 0,
		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.bind(mainMod .. " + Return",        hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + Q",             hl.dsp.window.close())
hl.bind(mainMod .. " + M",             hl.dsp.exec_cmd("hyprctl dispatch exit"))
hl.bind(mainMod .. " + Space",         hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + V",             hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P",             hl.dsp.window.pseudo())

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key,          hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key,  hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
