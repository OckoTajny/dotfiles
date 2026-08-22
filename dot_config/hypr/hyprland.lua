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

-- Workspace prev/next on the bottom-row pair. Hyprland resolves these keysyms
-- to keycodes (input:resolve_binds_by_sym is false), so they follow the physical
-- keys across layouts. Rebound here to override Ambxst's own Z/X binds.
hl.unbind("SUPER + Z")
hl.unbind("SUPER + X")
hl.unbind("SUPER + SHIFT + Z")
hl.unbind("SUPER + SHIFT + X")
hl.bind("SUPER + Z", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + X", hl.dsp.focus({ workspace = "+1" }))
-- The SUPER + SHIFT + Z unbind above also removes the accurate-dictation bind
-- from custom/keybinds.lua (this file loads later, so the unbind wins). Put it
-- back here, after the unbind.
hl.bind("SUPER + SHIFT + Z", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/voice-to-text large-v3-turbo"))

-- Claude Code with permission prompts disabled, in $HOME. Takes over Ambxst's
-- settings window bind; settings are still reachable via `ambxst run config`.
hl.unbind("SUPER + SHIFT + C")
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd(
    "kitty --class claude-code --directory " .. os.getenv("HOME") ..
    " -e " .. os.getenv("HOME") .. "/.local/bin/claude --dangerously-skip-permissions"))

-- Scratchpad on SUPER + S, as in the pre-Ambxst config. Ambxst binds S to its
-- tools panel, which is already on SUPER + SHIFT + T (custom/keybinds.lua), so
-- the scratchpad toggle was the one that got lost.
hl.unbind("SUPER + S")
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special({}))
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special", silent = true }))

-- Scratchpad animation. Ambxst only configures windows/border/fade/workspaces,
-- so specialWorkspaceIn/Out stay at speed 0 with no curve and the scratchpad
-- snaps in instead of sliding. These are the values from the pre-Ambxst config.
hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 2.8, bezier = "emphasizedDecel", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 1.2, bezier = "emphasizedAccel", style = "slidevert" })
