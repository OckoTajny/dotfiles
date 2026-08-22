-- See https://wiki.hyprland.org/Configuring/Binds/
local home = os.getenv("HOME")
local bin  = home .. "/.local/bin/"

---------------
---- Shell ----
---------------
hl.bind("CTRL + SUPER + Slash", hl.dsp.exec_cmd("xdg-open " .. home .. "/.config/illogical-impulse/config.json"))
hl.bind("CTRL + SUPER + ALT + Slash", hl.dsp.exec_cmd("xdg-open " .. home .. "/.config/hypr/custom/keybinds.lua"))

--------------
---- Apps ----
--------------
hl.bind("SUPER + C", hl.dsp.exec_cmd(home .. "/.local/share/JetBrains/Toolbox/scripts/idea")) -- IntelliJ IDEA
hl.bind("SUPER + I", hl.dsp.exec_cmd(home .. "/.local/share/JetBrains/Toolbox/scripts/idea")) -- IntelliJ IDEA
hl.bind("SUPER + O", hl.dsp.exec_cmd("flatpak run org.onlyoffice.desktopeditors"))            -- OnlyOffice

-- Kept from illogical-impulse (Ambxst swap)
hl.bind("SUPER + W", hl.dsp.exec_cmd("zen-browser")) -- Browser
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))    -- File manager
hl.bind("SUPER + B", hl.dsp.exec_cmd("kitty -e btop"))
hl.bind("SUPER + Return", hl.dsp.exec_cmd(
    [[kitty -e brrtfetch -width 50 -height 50 -info "fastfetch --logo-type none --color-keys magenta --color-title magenta" ]] ..
    home .. "/brrtfetch/gifs/distro/linux/arch-purple-glitch-transparent.gif")) -- Terminal + brrtfetch
-- SUPER + T is bound in hyprland.lua's OVERRIDES section (must beat Ambxst's tmux bind)
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("kitty")) -- Terminal (Ubuntu muscle memory)

hl.bind("SHIFT + SUPER + F23", hl.dsp.exec_cmd("discord"))        -- Copilot key (xkb FK23 = keycode 201) -> Discord
hl.bind("CTRL + SHIFT + SUPER + F23", hl.dsp.exec_cmd("spotify")) -- Ctrl+Copilot -> Spotify

------------------------
---- Window actions ----
------------------------
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized" }))        -- Maximize (keep gaps + bar)
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- Fullscreen (true)
hl.bind("SUPER + Q", hl.dsp.window.close())                                  -- Close window
hl.bind("SUPER + mouse:274", hl.dsp.window.close())                          -- Close window (Super + wheel click)
hl.bind("ALT + F4", hl.dsp.window.close())                                   -- Close window (Windows muscle memory)
-- Alt+Tab: switch to last-focused window (crosses workspaces, unlike cyclenext)
hl.bind("ALT + Tab", hl.dsp.focus({ last = true }))

-----------------
---- dotswap ----
-----------------
hl.bind("CTRL + SUPER + P", hl.dsp.exec_cmd(bin .. "dotswap use win11 && " .. bin .. "dotswap-postapply win11"))
hl.bind("CTRL + SHIFT + SUPER + Right", hl.dsp.exec_cmd(bin .. "dotswap-cycle next"))
hl.bind("CTRL + SHIFT + SUPER + Left", hl.dsp.exec_cmd(bin .. "dotswap-cycle prev"))
-- Fav layout: IDEA ws1, Spotify ws2, Discord ws3, Zen special
hl.bind("CTRL + SHIFT + SUPER + W", hl.dsp.exec_cmd(bin .. "hypr-fav-layout"))

---------------------
---- Screenshots ----
---------------------
hl.bind("Print", hl.dsp.exec_cmd("ambxst run screenshot"), { locked = true }) -- Region screenshot (Ambxst UI)
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    [[mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim -o "$(hyprctl activeworkspace -j | jq -r '.monitor')" ]] ..
    [[$(xdg-user-dir PICTURES)/Screenshots/Screenshot_"$(date '+%Y-%m-%d_%H.%M.%S')".png]]),
    { locked = true }) -- Fullscreen screenshot >> file
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(
    [[grim -o "$(hyprctl activeworkspace -j | jq -r '.monitor')" - | wl-copy]]),
    { locked = true }) -- Fullscreen screenshot >> clipboard

--------------------
---- Workspaces ----
--------------------
-- Hyprland resolves keysym binds to keycodes (input:resolve_binds_by_sym is
-- false), so these follow the physical number row on both layouts. The old
-- "code:NN" spelling is NOT understood by the Lua provider: it registered
-- binds with an empty key that could never fire.
local digits = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
for i = 1, 10 do
    local code = digits[i]
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
-- Y on us = Z on cz (top row); resolved by keycode, so either layout hits it.
hl.bind("SUPER + Y", hl.dsp.exec_cmd(bin .. "voice-to-text"))
-- Accurate model (better Czech, slower) — Z on us = Y on cz
hl.bind("SUPER + SHIFT + Z", hl.dsp.exec_cmd(bin .. "voice-to-text large-v3-turbo"))

hl.bind("SUPER + Space", hl.dsp.exec_cmd(bin .. "kb-toggle"))            -- Keyboard layout toggle (us <-> cz)
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd(bin .. "set-primary-monitor")) -- Pick the primary monitor (0,0)
hl.bind("SUPER + P", hl.dsp.exec_cmd(bin .. "sudo-passwd-toggle"))       -- Toggle passwordless sudo
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("ambxst run tools"))        -- Ambxst tools panel (also Super+Shift+V)
