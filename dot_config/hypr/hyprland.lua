-- Hyprland config (Lua). Hyprland 0.57 drops the .conf format, so the whole
-- tree lives in Lua now.
--
-- `hyprland/` is the illogical-impulse upstream tree, vendored verbatim from
-- end-4/dots-hyprland — don't edit those files, they get replaced wholesale on
-- the next update. Your own stuff goes in `custom/` or in OVERRIDES below.
--
-- Load order matters: later writes win, and Ambxst is loaded last on purpose
-- so its theme/keybinds beat the illogical-impulse defaults.

-- Internal helpers (HOME, is_file_exists, workspace_in_group)
require("hyprland.lib")

-- Environment variables
require("hyprland.env")
require("custom.env")

-- Defaults
-- (hyprland/execs.lua and hyprland/keybinds.lua stay unloaded: Ambxst provides
--  the autostart and the keybinds. hyprland/services and hyprland/shellOverrides
--  are illogical-impulse shell plumbing and are unused here as well.)
require("hyprland.general")
require("hyprland.rules")
require("hyprland.colors")

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

-- Claude Code with permission prompts disabled, in $HOME. Takes over Ambxst's
-- settings window bind; settings are still reachable via `ambxst run config`.
hl.unbind("SUPER + SHIFT + C")
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd(
    "kitty --class claude-code --directory " .. os.getenv("HOME") ..
    " -e " .. os.getenv("HOME") .. "/.local/bin/claude --dangerously-skip-permissions"))
