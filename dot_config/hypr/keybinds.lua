-- ~/.config/hypr/keybinds.lua
-- 43PR rice with the same keybinds as the ambxst profile
-- (custom/keybinds.lua + the Ambxst defaults + the OVERRIDES block in its
-- hyprland.lua). Ambxst-only actions (dashboard, launcher, clipboard,
-- wallpapers, power menu, screenshot UI …) are mapped to their 43PR
-- counterparts: rofi, cliphist, hyprquickpaper, wlogout, grim/slurp.
-- Docs: https://wiki.hyprland.org/Configuring/Binds/
--       https://wiki.hyprland.org/Configuring/Dispatchers/

local home = os.getenv("HOME")
local bin  = home .. "/.local/bin/"

-- Preferred programs
local terminal    = "kitty"
local browser     = "zen-browser"
local fileManager = "nautilus"
if os.execute("command -v nautilus >/dev/null 2>&1") ~= 0 then
    fileManager = "thunar"
end

-- rofi toggles: a second press closes the menu instead of stacking a new one
local launcher  = "pgrep -x rofi >/dev/null && pkill -x rofi || rofi -show drun"
local clipboard = "pgrep -x rofi >/dev/null && pkill -x rofi || cliphist list | rofi -dmenu -p '' | cliphist decode | wl-copy"
local windows   = "pgrep -x rofi >/dev/null && pkill -x rofi || rofi -show window"
local powermenu = "pgrep -x wlogout >/dev/null || wlogout -b 1 -c 20 -r 20 -L 1700 -R 1700 -T 325 -B 325"
local wallpapers = "quickshell -n -c hyprquickpaper"

-- Region screenshot -> ~/Pictures/Screenshots + clipboard (replaces
-- `ambxst run screenshot`)
local shot_region = [[mkdir -p $(xdg-user-dir PICTURES)/Screenshots && f=$(xdg-user-dir PICTURES)/Screenshots/Screenshot_"$(date '+%Y-%m-%d_%H.%M.%S')".png && grim -g "$(slurp)" "$f" && wl-copy < "$f"]]
-- Screen recorder toggle on the active monitor (replaces `ambxst run screenrecord`)
local screenrecord = "bash -c '"
    .. "PIDFILE=/tmp/dotswap-gsr.pid; "
    .. "if [ -f \"$PIDFILE\" ] && kill -0 \"$(cat \"$PIDFILE\")\" 2>/dev/null; then "
    ..   "kill -INT \"$(cat \"$PIDFILE\")\"; rm -f \"$PIDFILE\"; notify-send \"Recording saved\" \"~/Videos\"; "
    .. "else "
    ..   "mkdir -p ~/Videos; mon=$(hyprctl activeworkspace -j | jq -r .monitor); "
    ..   "gpu-screen-recorder -w \"$mon\" -f 60 -a default_output -o ~/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4 & echo $! > \"$PIDFILE\"; "
    ..   "notify-send \"Recording started\" \"$mon\"; "
    .. "fi'"

---------------
---- Shell ----
---------------
hl.bind("CTRL + SUPER + Slash", hl.dsp.exec_cmd("xdg-open " .. home .. "/.config/waybar/config.jsonc"))
hl.bind("CTRL + SUPER + ALT + Slash", hl.dsp.exec_cmd("xdg-open " .. home .. "/.config/hypr/keybinds.lua"))

hl.bind("SUPER + D", hl.dsp.exec_cmd(launcher))          -- App launcher (Ambxst: dashboard)
hl.bind("SUPER + V", hl.dsp.exec_cmd(clipboard))         -- Clipboard history
hl.bind("SUPER + TAB", hl.dsp.exec_cmd(windows))         -- Window overview
hl.bind("SUPER + COMMA", hl.dsp.exec_cmd(wallpapers))    -- Wallpaper picker
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd(wallpapers))  -- Wallpaper picker (43PR default)
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd(powermenu))    -- Power menu
hl.bind("SUPER + GRAVE", hl.dsp.exec_cmd(powermenu))     -- Power menu (43PR default)
hl.bind("SUPER + L", hl.dsp.exec_cmd("pgrep -x hyprlock >/dev/null || hyprlock"))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("sh -c 'pgrep -x waybar >/dev/null && pkill -x waybar || nohup waybar >/dev/null 2>&1 &'")) -- Toggle waybar
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd("sh -c 'pkill -x waybar; nohup waybar >/dev/null 2>&1 &'")) -- Restart bar (Ambxst: reload)
hl.bind("SUPER + ALT + O", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/opacity.sh")) -- Window opacity toggle (43PR)

--------------
---- Apps ----
--------------
hl.bind("SUPER + C", hl.dsp.exec_cmd(home .. "/.local/share/JetBrains/Toolbox/scripts/idea")) -- IntelliJ IDEA
hl.bind("SUPER + I", hl.dsp.exec_cmd(home .. "/.local/share/JetBrains/Toolbox/scripts/idea")) -- IntelliJ IDEA
hl.bind("SUPER + O", hl.dsp.exec_cmd("flatpak run org.onlyoffice.desktopeditors"))            -- OnlyOffice

hl.bind("SUPER + W", hl.dsp.exec_cmd(browser))     -- Browser
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager)) -- File manager
hl.bind("SUPER + B", hl.dsp.exec_cmd(terminal .. " -e btop"))

-- Terminal + brrtfetch (plain terminal when brrtfetch isn't built)
local brrt_gif = home .. "/brrtfetch/gifs/distro/linux/arch-purple-glitch-transparent.gif"
local term_cmd = terminal
if io.open(brrt_gif, "r") ~= nil then
    term_cmd = terminal .. [[ -e brrtfetch -width 50 -height 50 -info "fastfetch --logo-type none --color-keys magenta --color-title magenta" ]] .. brrt_gif
end
hl.bind("SUPER + Return", hl.dsp.exec_cmd(term_cmd))
hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(terminal)) -- Terminal (Ubuntu muscle memory)

-- Claude Code with permission prompts disabled, in $HOME
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd(
    "kitty --class claude-code --directory " .. home ..
    " -e " .. bin .. "claude --dangerously-skip-permissions"))

hl.bind("SHIFT + SUPER + F23", hl.dsp.exec_cmd("discord"))        -- Copilot key (xkb FK23 = keycode 201) -> Discord
hl.bind("CTRL + SHIFT + SUPER + F23", hl.dsp.exec_cmd("spotify")) -- Ctrl+Copilot -> Spotify

------------------------
---- Window actions ----
------------------------
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized" }))          -- Maximize (keep gaps + bar)
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- Fullscreen (true)
hl.bind("SUPER + Q", hl.dsp.window.close())                                     -- Close window
hl.bind("SUPER + mouse:274", hl.dsp.window.close())                             -- Close window (Super + wheel click)
hl.bind("ALT + F4", hl.dsp.window.close())                                      -- Close window (Windows muscle memory)
-- Alt+Tab: switch to last-focused window (crosses workspaces, unlike cyclenext)
hl.bind("ALT + Tab", hl.dsp.focus({ last = true }))

-- Toggle float, centred at 70 % of the monitor (43PR)
hl.bind("SUPER + ALT + Space", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    local w = hl.get_active_window()
    if w ~= nil and w.floating then
        local mon = hl.get_active_monitor()
        if mon ~= nil then
            local target_w = math.floor(mon.width * 0.7)
            local target_h = math.floor(mon.height * 0.7)
            hl.dispatch(hl.dsp.window.resize({ x = target_w, y = target_h, relative = false }))
            local target_x = (mon.x or 0) + math.floor((mon.width - target_w) / 2)
            local target_y = (mon.y or 0) + math.floor((mon.height - target_h) / 2)
            hl.dispatch(hl.dsp.window.move({ x = target_x, y = target_y, relative = false }))
        end
    end
end)

-- Mouse drag/resize
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Scratchpad (special workspace)
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special({}))
hl.bind("SUPER + SHIFT + V", hl.dsp.workspace.toggle_special({}))
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special", silent = true }))
hl.bind("SUPER + ALT + V", hl.dsp.window.move({ workspace = "special" }))

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
hl.bind("Print", hl.dsp.exec_cmd(shot_region), { locked = true })           -- Region screenshot >> file + clipboard
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(shot_region), { locked = true }) -- same (Ambxst chord)
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    [[mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim -o "$(hyprctl activeworkspace -j | jq -r '.monitor')" ]] ..
    [[$(xdg-user-dir PICTURES)/Screenshots/Screenshot_"$(date '+%Y-%m-%d_%H.%M.%S')".png]]),
    { locked = true }) -- Fullscreen screenshot >> file
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(
    [[grim -o "$(hyprctl activeworkspace -j | jq -r '.monitor')" - | wl-copy]]),
    { locked = true }) -- Fullscreen screenshot >> clipboard
hl.bind("SUPER + Delete", hl.dsp.exec_cmd([[grim ]] .. home .. [[/Pictures/$(date +%s).png]])) -- 43PR: all monitors >> ~/Pictures
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd(screenrecord)) -- Screen record toggle

--------------------
---- Workspaces ----
--------------------
-- Hyprland resolves keysym binds to keycodes (input:resolve_binds_by_sym is
-- false), so these follow the physical number row on both layouts.
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

-- Workspace prev/next on the bottom-row pair + wheel
hl.bind("SUPER + Z", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + X", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e+1" }))

--------------------
---- Navigation ----
--------------------
-- Focus
hl.bind("SUPER + Left",  hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + Up",    hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + Down",  hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + CTRL + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + CTRL + z", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + CTRL + l", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + CTRL + x", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + CTRL + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + CTRL + j", hl.dsp.focus({ direction = "d" }))

-- Move window
hl.bind("SUPER + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + SHIFT + h",     hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + l",     hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + k",     hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + j",     hl.dsp.window.move({ direction = "d" }))

-- Resize window
hl.bind("SUPER + ALT + Right", hl.dsp.window.resize({ x = 50,  y = 0 }),   { repeating = true })
hl.bind("SUPER + ALT + Left",  hl.dsp.window.resize({ x = -50, y = 0 }),   { repeating = true })
hl.bind("SUPER + ALT + Up",    hl.dsp.window.resize({ x = 0,   y = -50 }), { repeating = true })
hl.bind("SUPER + ALT + Down",  hl.dsp.window.resize({ x = 0,   y = 50 }),  { repeating = true })
hl.bind("SUPER + ALT + l",     hl.dsp.window.resize({ x = 50,  y = 0 }),   { repeating = true })
hl.bind("SUPER + ALT + h",     hl.dsp.window.resize({ x = -50, y = 0 }),   { repeating = true })
hl.bind("SUPER + ALT + k",     hl.dsp.window.resize({ x = 0,   y = -50 }), { repeating = true })
hl.bind("SUPER + ALT + j",     hl.dsp.window.resize({ x = 0,   y = 50 }),  { repeating = true })

--------------
---- Zoom ---- (43PR: numpad +/-)
--------------
local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    if (zoomvalue + value) > 1.5 then
        hl.config({ cursor = { zoom_factor = 1.5 } })
    elseif (zoomvalue + value) < 1.0 then
        hl.config({ cursor = { zoom_factor = 1.0 } })
    else
        hl.config({ cursor = { zoom_factor = zoomvalue + value } })
    end
end
hl.bind("SUPER + KP_Subtract", function() zoomfunction(-0.3) end, { repeating = true })
hl.bind("SUPER + KP_Add",      function() zoomfunction(0.3) end,  { repeating = true })

-------------------
---- Utilities ----
-------------------
-- voice-to-text: toggle dictation (press to record, press again to transcribe+type).
-- Y on us = Z on cz (top row); resolved by keycode, so either layout hits it.
hl.bind("SUPER + Y", hl.dsp.exec_cmd(bin .. "voice-to-text"))
-- Accurate model (better Czech, slower) — Z on us = Y on cz
hl.bind("SUPER + SHIFT + Z", hl.dsp.exec_cmd(bin .. "voice-to-text large-v3-turbo"))

hl.bind("SUPER + Space", hl.dsp.exec_cmd(bin .. "kb-toggle"))               -- Keyboard layout toggle (us <-> cz)
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd(bin .. "set-primary-monitor")) -- Pick the primary monitor (0,0)
hl.bind("SUPER + P", hl.dsp.exec_cmd(bin .. "sudo-passwd-toggle"))          -- Toggle passwordless sudo

--------------------
---- Media/keys ----
--------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+"), { locked = true, release = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%-"), { locked = true, release = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, release = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioMedia",       hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop",        hl.dsp.exec_cmd("playerctl stop"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, release = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, release = true })

-- Laptop lid
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd("pgrep -x hyprlock >/dev/null || hyprlock"), { locked = true })

-- Exit Hyprland
hl.bind("SUPER + SHIFT + E", hl.dsp.exit())
