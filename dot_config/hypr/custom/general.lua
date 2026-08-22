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
