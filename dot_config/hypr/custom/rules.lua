-- Custom rules
-- Window/layer rules: https://wiki.hyprland.org/Configuring/Window-Rules/
-- Workspace rules: https://wiki.hyprland.org/Configuring/Workspace-Rules/

-- Global transparency for all windows:
-- hl.window_rule({ match = { class = ".*" }, opacity = "0.89 override 0.89 override" })

-- Disable blur for all xwayland apps:
-- hl.window_rule({ match = { xwayland = true }, no_blur = true })

-- Boot update prompt: floating centred window
hl.window_rule({
    match  = { class = "update-prompt" },
    float  = true,
    center = true,
    size   = "640 420",
})

-- Pinned windows in the Ambxst accent instead of the illogical-impulse blue
hl.window_rule({ match = { pin = true }, border_color = "rgba(ffb59eAA) rgba(ffb59e77)" })

-- Fix JetBrains IDE focus/rerendering problem (was in the old .conf tree;
-- upstream's Lua rules.lua doesn't carry it)
hl.window_rule({
    match            = { class = "^jetbrains-.*$", float = true, title = "^$|^\\s$|^win\\d+$" },
    no_initial_focus = true,
})
