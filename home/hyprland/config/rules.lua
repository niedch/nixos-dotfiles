-- Noctalia layer rules
hl.layer_rule({
    name  = "noctalia-no-anim",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim = true,
})

hl.layer_rule({
    name  = "noctalia-blur",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    ignore_alpha = 0.2,
    blur         = true,
    blur_popups  = true,
})

-- Noctalia window rules
hl.window_rule({
    name  = "noctalia-settings",
    match = { class = "dev.noctalia.Noctalia" },
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
    size  = "60% 80%",
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
