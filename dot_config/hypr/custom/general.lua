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

-- Ambxst-matched background. The upstream illogical-impulse colours
-- (hyprland/colors.lua) are its own blue palette and would otherwise show
-- through, because Ambxst only sets the window borders.
hl.config({
    misc = { background_color = "rgba(1d100dFF)" },
})

-- Machine settings that differ from the illogical-impulse defaults. Kept here
-- so hyprland/ stays a verbatim copy of upstream.
hl.config({
    input = {
        -- us FIRST on purpose. Hyprland resolves every keysym bind to a keycode
        -- through level 1 of the FIRST layout in this list, so with cz first the
        -- digits (which sit on shift level in Czech) resolve to nothing and every
        -- SUPER+1..0 bind silently dies -- ambxst's own included. Typing stays
        -- Czech: custom/execs.lua switches the ACTIVE layout to cz at startup,
        -- and Super+Space (kb-toggle) flips between them.
        kb_layout     = "us,cz",
        accel_profile = "flat",   -- no mouse acceleration
        touchpad      = { scroll_factor = 0.5 },
    },

    misc = {
        vrr = 1,                  -- variable refresh rate on (DP-2 is 180 Hz)
    },
})

-- Decoration values carried over from the old .conf tree. Upstream's Lua
-- defaults are different (rounding_power 2.5, shadow range 20 / offset 0 2 /
-- colour 00000020, blur.special off, dim_special 0.2) — drop this block to
-- follow upstream instead.
hl.config({
    decoration = {
        rounding_power = 2,
        blur           = { special = true },
        shadow         = {
            range  = 50,
            offset = "0 4",
            color  = "rgba(00000027)",
        },
        dim_special    = 0,
    },
})
