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
