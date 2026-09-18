-- ~/.config/hypr/hyprland.lua
-- Docs: https://wiki.hypr.land/Configuring/Start/

---- MY PROGRAMS ----

mainMod    = "SUPER"
terminal   = "kitty"
menu       = "rofi -show drun"
fileManager = "nautilus"
browser    = "zen-browser"


---- AUTOSTART ----

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("command -v dunst >/dev/null 2>&1 && dunst || mako")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("qs -d -c volume-osd")
    hl.exec_cmd("~/.local/bin/boot-update-prompt")

    -- Start on the Czech layout. kb_layout lists us first so that keysym
    -- binds resolve to the right keycodes (digits sit on the shift level in
    -- cz); this flips the ACTIVE layout to cz once the compositor is up.
    hl.exec_cmd("hyprctl switchxkblayout all 1")
end)

---- ENVIRONMENT VARIABLES ----

hl.env("XCURSOR_SIZE", "14")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")

---- INPUT ----

hl.config({
    input = {
        kb_layout = "us,cz",
        follow_mouse = 1,
        sensitivity = 0.5,
        accel_profile = "flat",   -- no mouse acceleration
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
        },
    },
})

---- TOUCHPAD GESTURES ----

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })  -- 3 fingers l/r = switch workspace
hl.gesture({ fingers = 4, direction = "up",   action = "fullscreen" })
hl.gesture({ fingers = 4, direction = "down", action = "close" })

hl.config({ gestures = { workspace_swipe_distance = 300, workspace_swipe_create_new = true } })

---- LOOK AND FEEL ----

hl.config({ render = { expand_undersized_textures = false}})
hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 3,
        border_size = 0,
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 8,
        blur = {
            enabled = true,
            size = 5,
            passes = 1,
            vibrancy = 0.2,
        },
        shadow = {
            enabled = true,
            range = 8,
            render_power = 3,
        },
    },
    animations = {
        enabled = true,
    },
})

-- Animations ported from the ambxst profile (material-expressive curves)
hl.curve("expressiveFastSpatial",    { type = "bezier", points = { {0.42, 1.67}, {0.21, 0.90} } })
hl.curve("expressiveSlowSpatial",    { type = "bezier", points = { {0.39, 1.29}, {0.35, 0.98} } })
hl.curve("expressiveDefaultSpatial", { type = "bezier", points = { {0.38, 1.21}, {0.22, 1.00} } })
hl.curve("emphasizedDecel", { type = "bezier", points = { {0.05, 0.7}, {0.1, 1} } })
hl.curve("emphasizedAccel", { type = "bezier", points = { {0.3, 0}, {0.8, 0.15} } })
hl.curve("standardDecel",   { type = "bezier", points = { {0, 0}, {0, 1} } })
hl.curve("menu_decel",      { type = "bezier", points = { {0.1, 1}, {0, 1} } })
hl.curve("menu_accel",      { type = "bezier", points = { {0.52, 0.03}, {0.72, 0.08} } })
hl.curve("stall",           { type = "bezier", points = { {1, -0.1}, {0.7, 0.85} } })

hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3,   bezier = "emphasizedDecel", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2,   bezier = "emphasizedDecel", style = "popin 90%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 3,   bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 3,   bezier = "emphasizedDecel" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 2,   bezier = "emphasizedDecel" })
hl.animation({ leaf = "border",        enabled = true, speed = 10,  bezier = "emphasizedDecel" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 2.7, bezier = "emphasizedDecel", style = "popin 93%" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2.4, bezier = "menu_accel",      style = "popin 94%" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 0.5, bezier = "menu_decel" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.7, bezier = "stall" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 7,   bezier = "menu_decel", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 3,   bezier = "standardDecel" })

-- LAYOUT
hl.config({
    dwindle = { preserve_split = true },
})
hl.config({
    master = { new_status = "master" },
})

-- MISC
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

---- SPLIT-OUT FILES ----

-- monitors.lua is machine-specific: chezmoi creates it once from the source's
-- create_monitors.lua (generic "any monitor, preferred mode") and
-- ~/.local/bin/set-primary-monitor (Super+Shift+M) rewrites it afterwards.
if not pcall(require, "monitors") then
    print("monitors.lua missing – run set-primary-monitor; using preferred mode on every output")
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
end
require("keybinds")
require("rules")

local ok, err = pcall(require, "hyprland-gui")
if not ok then
    print("hyprland-gui not found, skipping (install HyprMod to enable it)")
end
