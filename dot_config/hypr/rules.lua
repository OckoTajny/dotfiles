-- ~/.config/hypr/rules.lua
-- Migrated from rules.conf
-- Docs: https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.layer_rule({
    match = { namespace = "rofi" },
    blur = true,
    ignore_alpha = 0.15,
})

-- Opacity rules: 90% for all windows except fullscreen
hl.window_rule({
    match = { class = ".*" },
    opacity = "0.9 override",
})

hl.window_rule({
    match = { class = ".*", fullscreen = true },
    opacity = "1.0 override",
})

hl.window_rule({
    name = "float-pavucontrol",
    match = { class = "^(pavucontrol)$" },
    float = true,
})

hl.window_rule({
    name = "float-nm-connection-editor",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
})

hl.window_rule({
    name = "float-blueman-manager",
    match = { class = "^(blueman-manager)$" },
    float = true,
})

hl.window_rule({
    name = "float-open-file",
    match = { title = "^(Open File)$" },
    float = true,
})

hl.window_rule({
    name = "float-save-file",
    match = { title = "^(Save File)$" },
    float = true,
})

-- Boot update prompt: floating centred window
hl.window_rule({
    match  = { class = "update-prompt" },
    float  = true,
    center = true,
    size   = "640 420",
})

-- Fix JetBrains IDE focus/rerendering problem
hl.window_rule({
    match            = { class = "^jetbrains-.*$", float = true, title = "^$|^\\s$|^win\\d+$" },
    no_initial_focus = true,
})

-- Games fullscreen rule
hl.window_rule({
    match            = { class = "^(cs2|steam_app_\\d+)$", title = "^(.+)$" },
    fullscreen_state = 2,
    sync_fullscreen  = true,
    decorate         = false,
})

