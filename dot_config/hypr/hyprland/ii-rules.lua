-- Window / workspace / layer rules (illogical-impulse defaults, Lua port of hyprland/rules.conf)

----------------------
---- Window rules ----
----------------------

-- Disable blur for xwayland context menus
hl.window_rule({ match = { class = "^()$", title = "^()$" }, no_blur = true })

-- Disable blur for every window
hl.window_rule({ match = { class = ".*" }, no_blur = true })

-- Floating
local float_titles = {
    "^(Open File)(.*)$",
    "^(Open Folder)(.*)$",
    "^(Save As)(.*)$",
    "^(Select a File)(.*)$",
    "^(Library)(.*)$",
    "^(File Upload)(.*)$",
    "^(.*)(wants to save)$",
    "^(.*)(wants to open)$",
}
for _, t in ipairs(float_titles) do
    hl.window_rule({ match = { title = t }, float = true, center = true })
end

hl.window_rule({
    match  = { title = "^(Choose wallpaper)(.*)$" },
    float  = true,
    center = true,
    size   = "(monitor_w*.60) (monitor_h*.65)",
})

hl.window_rule({ match = { class = "^(blueberry\\.py)$" }, float = true })
hl.window_rule({ match = { class = "^(guifetch)$" }, float = true }) -- FlafyDev/guifetch
hl.window_rule({ match = { class = ".*plasmawindowed.*" }, float = true })
hl.window_rule({ match = { class = "kcm_.*" }, float = true })
hl.window_rule({ match = { class = ".*bluedevilwizard" }, float = true })
hl.window_rule({ match = { title = ".*Welcome" }, float = true })
hl.window_rule({ match = { title = "^(illogical-impulse Settings)$" }, float = true })
hl.window_rule({ match = { title = ".*Shell conflicts.*" }, float = true })

local float_45 = {
    "^(pavucontrol)$",
    "^(org.pulseaudio.pavucontrol)$",
    "^(nm-connection-editor)$",
    "^(Zotero)$",
}
for _, c in ipairs(float_45) do
    hl.window_rule({
        match  = { class = c },
        float  = true,
        center = true,
        size   = "(monitor_w*.45) (monitor_h*.45)",
    })
end

hl.window_rule({
    match = { class = "org.freedesktop.impl.portal.desktop.kde" },
    float = true,
    size  = "(monitor_w*.60) (monitor_h*.65)",
})

-- Move
-- kde-material-you-colors spawns a window when changing dark/light theme.
-- This shoves it off-screen so it can't interfere at all.
hl.window_rule({
    match            = { class = "^(plasma-changeicons)$" },
    float            = true,
    no_initial_focus = true,
    move             = "999999 999999",
})

-- Dolphin's copy dialog insists on a silly position
hl.window_rule({ match = { title = "^(Copying — Dolphin)$" }, move = "40 80" })

-- Tiling
hl.window_rule({ match = { class = "^dev\\.warp\\.Warp$" }, tile = true })

-- Picture-in-Picture
hl.window_rule({
    match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float             = true,
    pin               = true,
    keep_aspect_ratio = true,
    move              = "(monitor_w*.73) (monitor_h*.72)",
    size              = "(monitor_w*.25) (monitor_h*.25)",
})

-- Screen sharing indicator
hl.window_rule({
    match = { title = ".*is sharing (a window|your screen).*" },
    float = true,
    pin   = true,
    move  = "(monitor_w*.5-window_w*.5) (monitor_h-window_h-12)",
})

-- Tearing
hl.window_rule({ match = { title = ".*\\.exe" }, immediate = true })
hl.window_rule({ match = { title = ".*minecraft.*" }, immediate = true })
hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })

-- Fix JetBrains IDE focus/rerendering problem
hl.window_rule({
    match            = { class = "^jetbrains-.*$", float = true, title = "^$|^\\s$|^win\\d+$" },
    no_initial_focus = true,
})

-- No shadow for tiled windows
hl.window_rule({ match = { float = false }, no_shadow = true })

-------------------------
---- Workspace rules ----
-------------------------

hl.workspace_rule({ workspace = "special:special", gaps_out = 30 })

---------------------
---- Layer rules ----
---------------------

hl.layer_rule({ match = { namespace = ".*" }, xray = true })

for _, ns in ipairs({ "walker", "selection", "overview", "anyrun", "indicator.*", "osk", "hyprpicker", "noanim" }) do
    hl.layer_rule({ match = { namespace = ns }, no_anim = true })
end

hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.69 })
-- Upstream .conf had `layerrule = match:namespace logout_dialog # wlogout, blur on`,
-- where the `#` comment swallowed the property and the rule did nothing. Intent kept here.
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true }) -- wlogout

-- ags
hl.layer_rule({ match = { namespace = "sideleft.*" }, animation = "slide left" })
hl.layer_rule({ match = { namespace = "sideright.*" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "session[0-9]*" }, blur = true })
for _, ns in ipairs({
    "bar[0-9]*", "barcorner.*", "dock[0-9]*", "indicator.*", "overview[0-9]*",
    "cheatsheet[0-9]*", "sideright[0-9]*", "sideleft[0-9]*", "osk[0-9]*",
}) do
    hl.layer_rule({ match = { namespace = ns }, blur = true, ignore_alpha = 0.6 })
end

-- Quickshell: illogical-impulse
hl.layer_rule({ match = { namespace = "quickshell:.*" }, blur = true, blur_popups = true, ignore_alpha = 0.79 })
hl.layer_rule({ match = { namespace = "quickshell:bar" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "quickshell:actionCenter" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:cheatsheet" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:dock" }, animation = "slide bottom" })
hl.layer_rule({ match = { namespace = "quickshell:screenCorners" }, animation = "popin 120%" })
hl.layer_rule({ match = { namespace = "quickshell:lockWindowPusher" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:notificationPopup" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:overlay" }, no_anim = true, ignore_alpha = 1 })
hl.layer_rule({ match = { namespace = "quickshell:overview" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:osk" }, animation = "slide bottom", order = -1 })
hl.layer_rule({ match = { namespace = "quickshell:polkit" }, no_anim = true })
-- xray off + ignore_alpha 1: keeps bar tooltips from picking up a weird colour
hl.layer_rule({ match = { namespace = "quickshell:popup" }, xray = false, ignore_alpha = 1 })
hl.layer_rule({ match = { namespace = "quickshell:mediaControls" }, ignore_alpha = 1 })
hl.layer_rule({ match = { namespace = "quickshell:reloadPopup" }, animation = "slide" })
hl.layer_rule({ match = { namespace = "quickshell:regionSelector" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:screenshot" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:session" }, blur = true, no_anim = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "quickshell:sidebarRight" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "quickshell:sidebarLeft" }, animation = "slide left" })
hl.layer_rule({ match = { namespace = "quickshell:verticalBar" }, animation = "slide" })

-- Quickshell: waffles
hl.layer_rule({ match = { namespace = "quickshell:wallpaperSelector" }, animation = "slide top" })
hl.layer_rule({ match = { namespace = "quickshell:wNotificationCenter" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:wOnScreenDisplay" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:wStartMenu" }, no_anim = true })
hl.layer_rule({ match = { namespace = "quickshell:wTaskView" }, no_anim = true, ignore_alpha = 0 })

-- Launchers need to be FAST
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, no_anim = true })
