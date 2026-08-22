-- General config overrides
-- Every variable: https://wiki.hyprland.org/Configuring/Variables/

hl.config({
    cursor = {
        no_hardware_cursors = false,
        default_monitor     = "DP-2",
    },
})

hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")

-- Workspace 1's monitor is NOT pinned here — it lives in monitors.lua, written
-- by ~/.local/bin/set-primary-monitor (Super+Shift+M). Hardcoding a monitor
-- name in this shared config meant the laptop, which has no DP-2, booted onto
-- workspace 2 instead.

-- Input. The Lua port of this profile loads hyprland/general.lua, which no
-- longer carries the input block (it moved to hyprland/input.lua, and that file
-- belongs to the caelestia tree and is never required here). Ambxst sets no
-- input options either, so without this the compositor falls back to a single
-- "us" layout and Super+Space (kb-toggle) has nothing to cycle to.
-- Values carried over from the pre-Lua ambxst hyprland/general.conf.
hl.config({
    input = {
        -- us FIRST on purpose. Hyprland resolves every keysym bind to a keycode
        -- through level 1 of the FIRST layout in this list, so with cz first the
        -- digits (which sit on shift level in Czech) resolve to nothing and every
        -- SUPER+1..0 bind silently dies — ambxst's own included. Typing stays
        -- Czech: custom/execs.lua switches the ACTIVE layout to cz at startup,
        -- and Super+Space (kb-toggle) flips between them.
        kb_layout              = "us,cz",
        numlock_by_default     = true,
        repeat_delay           = 250,
        repeat_rate            = 35,
        accel_profile          = "flat",
        follow_mouse           = 1,
        off_window_axis_events = 2,

        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor        = 0.5,
        },
    },
})
