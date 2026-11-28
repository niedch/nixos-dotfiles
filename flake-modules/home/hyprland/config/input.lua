hl.config({
    input = {
        kb_layout  = "us",
        kb_options = "compose:caps,shift:both_capslock_cancel",
        repeat_rate = 40,
        repeat_delay = 250,
        numlock_by_default = true,
        sensitivity = 0.35,
        accel_profile = "flat",

        touchpad = {
            natural_scroll = true,
            clickfinger_behavior = true,
            scroll_factor = 0.4,
            disable_while_typing = false,
        },
    },
})

hl.device({
    name        = "at-translated-set-2-keyboard",
    kb_layout   = "at",
})

hl.device({
    name        = "corne-choc-pro-keyboard",
    kb_layout   = "us",
})

hl.device({
    name        = "roccat-roccat-vulcan-aimo",
    kb_layout   = "at",
})
