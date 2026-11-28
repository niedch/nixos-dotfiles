-- DMS layer rules
hl.layer_rule({
    name  = "dms-no-anim",
    match = {
        namespace = "^dms:.*$",
    },
    no_anim = true,
})

hl.layer_rule({
    name  = "dms-blur",
    match = {
        namespace = "^dms:.*$",
    },
    ignore_alpha = 0.2,
    blur         = true,
    blur_popups  = true,
})

-- DMS window rules
hl.window_rule({
    name  = "dms-floating",
    match = { class = "^(dev\\.duxlabs\\.shell)$" },
    float = true,
    size  = { 1080, 920 },
})

-- Media viewers floating rules (mpv, qimgv, okular)
hl.window_rule({
    name   = "media-viewers-floating",
    match  = { class = "^(mpv|qimgv|org\\.kde\\.okular|okular)$" },
    float  = true,
    center = true,
})

hl.window_rule({
    name  = "okular-size",
    match = { class = "^(org\\.kde\\.okular|okular)$" },
    size  = { "monitor_w * 0.6", "monitor_h * 0.8" },
})

-- Steam floating rules
hl.window_rule({
    name   = "steam-floating",
    match  = { class = "^([Ss]team)$" },
    float  = true,
    center = true,
})

hl.window_rule({
    name  = "steam-size",
    match = { class = "^([Ss]team)$", title = "^(Steam)$" },
    size  = { 1280, 800 },
})

hl.window_rule({
    name             = "steam-notifications",
    match            = { class = "^([Ss]team)$", title = "^(notificationtoasts.*)$" },
    no_initial_focus = true,
})

-- Dux calendar floating rule
hl.window_rule({
    name   = "dux-calendar-floating",
    match  = { class = "^(dev\\.duxlabs\\.calendar)$" },
    float  = true,
    center = true,
    size   = { 1100, 820 },
})

-- Streaming & workspace window rules
hl.window_rule({
    name    = "streaming-opacity",
    match   = { class = "^(chrome-.*amazon.*|chrome-.*twitch.*)$" },
    opacity = "1.0 1.0",
})

hl.window_rule({
    name    = "special-workspace-opacity",
    match   = { workspace = "s[true]" },
    opacity = "1.0 1.0",
})

hl.window_rule({
    name    = "fullscreen-opacity",
    match   = { fullscreen = true },
    opaque  = true,
    opacity = "1.0 override 1.0 override 1.0 override",
})

-- Smart gaps
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})
