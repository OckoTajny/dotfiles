-- General config. Ambxst (loaded last from hyprland.lua) sets general/decoration/
-- animations; this file carries the machine/input settings that used to come
-- from the illogical-impulse tree, which is no longer installed.
-- Every variable: https://wiki.hyprland.org/Configuring/Variables/

hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")

hl.config({
    input = {
        -- us FIRST on purpose. Hyprland resolves every keysym bind to a keycode
        -- through level 1 of the FIRST layout in this list, so with cz first the
        -- digits (which sit on shift level in Czech) resolve to nothing and every
        -- SUPER+1..0 bind silently dies -- ambxst's own included. Typing stays
        -- Czech: custom/execs.lua switches the ACTIVE layout to cz at startup,
        -- and Super+Space (kb-toggle) flips between them.
        kb_layout          = "us,cz",
        numlock_by_default = true,
        repeat_delay       = 250,
        repeat_rate        = 35,
        accel_profile      = "flat",   -- no mouse acceleration
        follow_mouse       = 1,
        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor        = 0.5,
        },
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        background_color         = "rgba(1d100dFF)", -- Ambxst-matched
        vrr                      = 1,                -- DP-2 is 180 Hz
        mouse_move_enables_dpms  = true,
        key_press_enables_dpms   = true,
        allow_session_lock_restore = true,
        focus_on_activate        = true,
    },

    cursor = {
        no_hardware_cursors = false,
        default_monitor     = "DP-2",
    },

    xwayland = { force_zero_scaling = true },
})

-- Workspace 1's monitor is NOT pinned here — it lives in monitors.lua.
