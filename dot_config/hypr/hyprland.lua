-- Hyprland config (Lua). Ported from the old .conf tree on 2026-08-05 because
-- Hyprland 0.57 drops .conf support; 0.56 already warns about it on startup.
-- The old files are kept next to this one as *.conf.bak for reference.
--
-- Put your own stuff in the files under `custom/`. The `hyprland/ii-*.lua`
-- files are the illogical-impulse defaults — edit those only if you mean to
-- diverge from upstream.

-- Environment variables
require("hyprland.ii-env")
require("custom.env")

-- Defaults
-- (hyprland/execs.conf and hyprland/keybinds.conf stay disabled: Ambxst
--  provides the autostart and the keybinds via axctl.)
require("hyprland.ii-general")
require("hyprland.ii-rules")
require("hyprland.ii-colors")

-- Custom
require("custom.execs")
require("custom.general")
require("custom.rules")
require("custom.keybinds")

-- Monitors and workspaces (monitors.lua is rewritten by set-primary-monitor)
require("workspaces")
require("monitors")

-- Ambxst
loadfile(os.getenv("HOME") .. "/.local/share/ambxst/hyprland.lua")()

--------------------
---- OVERRIDES ----
--------------------
-- Anything that has to beat Ambxst's own settings goes below.

-- Plain kitty instead of Ambxst's tmux selector
hl.unbind("SUPER + T")
hl.bind("SUPER + T", hl.dsp.exec_cmd("kitty"))

-- Workspace prev/next on the bottom-row pair, by keycode so it follows the
-- physical keys across layouts: code:52 = Z(us)/Y(cz), code:53 = X.
-- Ambxst's keysym binds break on cz, so drop them first.
hl.unbind("SUPER + Z")
hl.unbind("SUPER + X")
hl.unbind("SUPER + SHIFT + Z")
hl.unbind("SUPER + SHIFT + X")
hl.bind("SUPER + code:52", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + code:53", hl.dsp.focus({ workspace = "+1" }))
-- SUPER + SHIFT + code:52 (accurate dictation) is bound in custom/keybinds.lua
-- and survives the unbind above, which only removes the keysym-Z binding.
