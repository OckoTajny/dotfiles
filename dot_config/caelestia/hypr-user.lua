-- Personal Hyprland config for the caelestia profile. Loaded last by
-- ~/.config/hypr/hyprland.lua, so it beats the caelestia defaults.
-- Lua port of the old custom/keybinds.conf (Hyprland 0.57 drops .conf).
--
-- App launchers (terminal, browser, editor, file explorer) are NOT bound here —
-- caelestia binds SUPER + T/W/C/E to the app variables, which hypr-vars.lua sets.

local home = os.getenv("HOME")
local bin  = home .. "/.local/bin/"

-- Monitor layout, written by ~/.local/bin/set-primary-monitor (Super+Shift+M).
-- Caelestia's own hyprland.lua doesn't source these, so pull them in here.
if io.open(home .. "/.config/hypr/workspaces.lua") then require("workspaces") end
if io.open(home .. "/.config/hypr/monitors.lua") then require("monitors") end

---------------
---- Shell ----
---------------
hl.bind("CTRL + SUPER + Slash", hl.dsp.exec_cmd("xdg-open " .. home .. "/.config/caelestia/shell.json"))
hl.bind("CTRL + SUPER + ALT + Slash", hl.dsp.exec_cmd("xdg-open " .. home .. "/.config/caelestia/hypr-user.lua"))

--------------
---- Apps ----
--------------
hl.bind("SUPER + I", hl.dsp.exec_cmd(home .. "/.local/share/JetBrains/Toolbox/scripts/idea")) -- IntelliJ IDEA
hl.bind("SUPER + O", hl.dsp.exec_cmd("flatpak run org.onlyoffice.desktopeditors"))            -- OnlyOffice
hl.bind("SUPER + B", hl.dsp.exec_cmd("kitty -e btop"))
hl.bind("SUPER + Return", hl.dsp.exec_cmd(
    [[kitty -e brrtfetch -width 50 -height 50 -info "fastfetch --logo-type none --color-keys magenta --color-title magenta" ]] ..
    home .. "/brrtfetch/gifs/distro/linux/arch-purple-glitch-transparent.gif")) -- Terminal + brrtfetch
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("kitty")) -- Terminal (Ubuntu muscle memory)

hl.bind("SHIFT + SUPER + code:201", hl.dsp.exec_cmd("discord"))        -- Copilot key -> Discord
hl.bind("CTRL + SHIFT + SUPER + code:201", hl.dsp.exec_cmd("spotify")) -- Ctrl+Copilot -> Spotify

------------------------
---- Window actions ----
------------------------
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized" })) -- Maximize (keep gaps + bar)
hl.bind("ALT + F4", hl.dsp.window.close())                             -- Close window (Windows muscle memory)
-- Alt+Tab: switch to last-focused window (crosses workspaces, unlike cyclenext)
hl.bind("ALT + Tab", hl.dsp.focus({ last = true }))

-----------------
---- dotswap ----
-----------------
hl.bind("CTRL + SUPER + P", hl.dsp.exec_cmd(bin .. "dotswap use win11 && " .. bin .. "dotswap-postapply win11"))
hl.bind("CTRL + SHIFT + SUPER + Right", hl.dsp.exec_cmd(bin .. "dotswap-cycle next"))
hl.bind("CTRL + SHIFT + SUPER + Left", hl.dsp.exec_cmd(bin .. "dotswap-cycle prev"))

--------------------
---- Workspaces ----
--------------------
-- By keycode, not keysym: on the cz layout the digits need Shift, so caelestia's
-- keysym binds for 1-0 never fire. code:10..19 are the physical number-row keys.
for i = 1, 10 do
    local code = "code:" .. (i + 9)
    local ws   = tostring(i)
    hl.bind("SUPER + " .. code, hl.dsp.focus({ workspace = ws }))
    hl.bind("SUPER + SHIFT + " .. code, hl.dsp.window.move({ workspace = ws }))
    hl.bind("SUPER + ALT + " .. code, hl.dsp.window.move({ workspace = ws, silent = true }))
    hl.bind("CTRL + ALT + " .. code, hl.dsp.window.move({ workspace = ws }))

    -- Numpad (KP_1..KP_9, KP_0 — needs NumLock on)
    local kp = "KP_" .. (i % 10)
    hl.bind("SUPER + " .. kp, hl.dsp.focus({ workspace = ws }))
    hl.bind("SUPER + SHIFT + " .. kp, hl.dsp.window.move({ workspace = ws }))
    hl.bind("SUPER + ALT + " .. kp, hl.dsp.window.move({ workspace = ws, silent = true }))
end

-------------------
---- Utilities ----
-------------------
-- voice-to-text: toggle dictation (press to record, press again to transcribe+type).
-- code:29 = physical Y on us / Z on cz (top row) — layout-independent.
hl.bind("SUPER + code:29", hl.dsp.exec_cmd(bin .. "voice-to-text"))
-- Accurate model (better Czech, slower) — code:52 = Z on us / Y on cz
hl.bind("SUPER + SHIFT + code:52", hl.dsp.exec_cmd(bin .. "voice-to-text large-v3-turbo"))

hl.bind("SUPER + Space", hl.dsp.exec_cmd(bin .. "kb-toggle")) -- Keyboard layout toggle (us <-> cz)

-- Workspace prev/next is NOT rebound here: caelestia already has
-- CTRL + SUPER + Left/Right and SUPER + Page_Up/Down for it, and the keycode
-- pair used in the other profiles (code:52/53) is caelestia's move/resize window.
