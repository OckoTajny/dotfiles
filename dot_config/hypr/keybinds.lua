-- ~/.config/hypr/keybinds.lua
-- Configured for 43PR profile with custom keybinds mapping
-- Docs: https://wiki.hyprland.org/Configuring/Binds/
--       https://wiki.hyprland.org/Configuring/Dispatchers/

local home = os.getenv("HOME")
local bin  = home .. "/.local/bin/"
local mainMod = "SUPER"
local menu = "rofi -show drun"

-- Preferred programs
local terminal = "kitty"
local browser = "brave"
if os.execute("command -v zen-browser >/dev/null 2>&1") == 0 then
    browser = "zen-browser"
end
local fileManager = "nautilus"
if os.execute("command -v nautilus >/dev/null 2>&1") ~= 0 then
    fileManager = "thunar"
end

-------------------
---- Apps / UI ----
-------------------
-- IntelliJ IDEA
local idea_cmd = home .. "/.local/share/JetBrains/Toolbox/scripts/idea"
hl.bind("SUPER + C", hl.dsp.exec_cmd(idea_cmd))
hl.bind("SUPER + I", hl.dsp.exec_cmd(idea_cmd))

-- OnlyOffice
hl.bind("SUPER + O", hl.dsp.exec_cmd("flatpak run org.onlyoffice.desktopeditors"))

-- Browser & File Manager
hl.bind("SUPER + W", hl.dsp.exec_cmd(browser))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + B", hl.dsp.exec_cmd(terminal .. " -e btop"))

-- Terminal & Brrtfetch
local brrt_gif = home .. "/brrtfetch/gifs/distro/linux/arch-purple-glitch-transparent.gif"
local term_cmd = terminal
if io.open(brrt_gif, "r") ~= nil then
    term_cmd = terminal .. [[ -e brrtfetch -width 50 -height 50 -info "fastfetch --logo-type none --color-keys magenta --color-title magenta" ]] .. brrt_gif
end
hl.bind("SUPER + Return", hl.dsp.exec_cmd(term_cmd))
hl.bind("SUPER + T", hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd(terminal))

-- Copilot key (FK23 = keycode 201) -> Discord / Spotify
hl.bind("SHIFT + SUPER + F23", hl.dsp.exec_cmd("discord"))
hl.bind("CTRL + SHIFT + SUPER + F23", hl.dsp.exec_cmd("spotify"))

-----------------------
---- 43PR Ricing UI ---
-----------------------
-- Rofi application launcher
hl.bind("SUPER + D", hl.dsp.exec_cmd("pgrep -x rofi >/dev/null && pkill -x rofi || " .. menu))

-- Clipboard history via Rofi + cliphist
hl.bind("SUPER + V", hl.dsp.exec_cmd("pgrep -x rofi >/dev/null && pkill -x rofi || cliphist list | rofi -dmenu -p '' | cliphist decode | wl-copy"))

-- Wlogout session menu
hl.bind("SUPER + GRAVE", hl.dsp.exec_cmd("pgrep -x wlogout >/dev/null || wlogout -b 1 -c 20 -r 20 -L 1700 -R 1700 -T 325 -B 325"))

-- Lock screen
hl.bind("SUPER + Tab", hl.dsp.exec_cmd("hyprlock"))

-- Wallpaper selector (hyprquickpaper via quickshell)
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("quickshell -n -c hyprquickpaper"))

-- Toggle waybar
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd("sh -c 'pgrep -x waybar >/dev/null && pkill waybar || nohup waybar >/dev/null 2>&1 &'"))

-- Window opacity toggle
hl.bind("SUPER + ALT + O", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/opacity.sh"))

------------------------
---- Window actions ----
------------------------
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + mouse:274", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("ALT + Tab", hl.dsp.focus({ last = true }))

-- Toggle float window, center and resize to 70% of screen
hl.bind("SUPER + ALT + Space", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    local w = hl.get_active_window()
    if w ~= nil and w.floating then
        local mon = hl.get_active_monitor()
        if mon ~= nil then
            local target_w = math.floor(mon.width * 0.7)
            local target_h = math.floor(mon.height * 0.7)
            hl.dispatch(hl.dsp.window.resize({ x = target_w, y = target_h, relative = false }))
            local mon_x = mon.x or 0
            local mon_y = mon.y or 0
            local target_x = mon_x + math.floor((mon.width - target_w) / 2)
            local target_y = mon_y + math.floor((mon.height - target_h) / 2)
            hl.dispatch(hl.dsp.window.move({ x = target_x, y = target_y, relative = false }))
        end
    end
end)

-- Mouse drag/resize
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-----------------
---- dotswap ----
-----------------
hl.bind("CTRL + SUPER + P", hl.dsp.exec_cmd(bin .. "dotswap use win11 && " .. bin .. "dotswap-postapply win11"))
hl.bind("CTRL + SHIFT + SUPER + Right", hl.dsp.exec_cmd(bin .. "dotswap-cycle next"))
hl.bind("CTRL + SHIFT + SUPER + Left", hl.dsp.exec_cmd(bin .. "dotswap-cycle prev"))
hl.bind("CTRL + SHIFT + SUPER + W", hl.dsp.exec_cmd(bin .. "hypr-fav-layout"))

-------------------
---- Utilities ----
-------------------
hl.bind("SUPER + Space", hl.dsp.exec_cmd(bin .. "kb-toggle"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("hyprctl switchxkblayout current next"))
hl.bind("SUPER + Y", hl.dsp.exec_cmd(bin .. "voice-to-text"))
hl.bind("SUPER + SHIFT + Z", hl.dsp.exec_cmd(bin .. "voice-to-text large-v3-turbo"))
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd(bin .. "set-primary-monitor"))
hl.bind("SUPER + P", hl.dsp.exec_cmd(bin .. "sudo-passwd-toggle"))

-- GPU screen recorder (from 43PR)
hl.bind("SUPER + R", hl.dsp.exec_cmd(
    "bash -c 'PIDFILE=/tmp/osu-gsr.pid; if [ -f \"$PIDFILE\" ] && kill -0 \"$(cat \"$PIDFILE\")\" 2>/dev/null; then kill -INT \"$(cat \"$PIDFILE\")\"; rm -f \"$PIDFILE\"; else mkdir -p ~/Videos; gpu-screen-recorder -w HDMI-A-1 -f 60 -a default_output -o ~/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4 & echo $! > \"$PIDFILE\"; fi'"
))

---------------------
---- Screenshots ----
---------------------
hl.bind("Print", hl.dsp.exec_cmd([[grim -g "$(slurp)" $(xdg-user-dir PICTURES)/Screenshots/Screenshot_"$(date '+%Y-%m-%d_%H.%M.%S')".png]]), { locked = true })
hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    [[mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim -o "$(hyprctl activeworkspace -j | jq -r '.monitor')" ]] ..
    [[$(xdg-user-dir PICTURES)/Screenshots/Screenshot_"$(date '+%Y-%m-%d_%H.%M.%S')".png]]),
    { locked = true })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(
    [[grim -o "$(hyprctl activeworkspace -j | jq -r '.monitor')" - | wl-copy]]),
    { locked = true })
-- 43PR alternative screenshot keys
hl.bind("Delete", hl.dsp.exec_cmd([[grim -g "$(slurp)" ]] .. home .. [[/Pictures/$(date +%s).png]]))
hl.bind("SUPER + Delete", hl.dsp.exec_cmd([[grim ]] .. home .. [[/Pictures/$(date +%s).png]]))

--------------------
---- Workspaces ----
--------------------
local digits = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
for i = 1, 10 do
    local code = digits[i]
    local ws   = tostring(i)
    hl.bind("SUPER + " .. code, hl.dsp.focus({ workspace = ws }))
    hl.bind("SUPER + SHIFT + " .. code, hl.dsp.window.move({ workspace = ws }))
    hl.bind("SUPER + ALT + " .. code, hl.dsp.window.move({ workspace = ws, silent = true }))
    hl.bind("CTRL + ALT + " .. code, hl.dsp.window.move({ workspace = ws }))

    -- Numpad (KP_1..KP_9, KP_0)
    local kp = "KP_" .. (i % 10)
    hl.bind("SUPER + " .. kp, hl.dsp.focus({ workspace = ws }))
    hl.bind("SUPER + SHIFT + " .. kp, hl.dsp.window.move({ workspace = ws }))
    hl.bind("SUPER + ALT + " .. kp, hl.dsp.window.move({ workspace = ws, silent = true }))
end

--------------------
---- Navigation ----
--------------------
-- Focus
hl.bind("SUPER + Left",  hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + Up",    hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + Down",  hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + H",     hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + L",     hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + K",     hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J",     hl.dsp.focus({ direction = "down" }))

-- Move window
hl.bind("SUPER + SHIFT + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + Down",  hl.dsp.window.move({ direction = "d" }))
hl.bind("SUPER + SHIFT + H",     hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + L",     hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))

-- Resize window
hl.bind("SUPER + ALT + Right", hl.dsp.exec_cmd("resizeactive 50 0"))
hl.bind("SUPER + ALT + Left",  hl.dsp.exec_cmd("resizeactive -50 0"))
hl.bind("SUPER + ALT + Up",    hl.dsp.exec_cmd("resizeactive 0 -50"))
hl.bind("SUPER + ALT + Down",  hl.dsp.exec_cmd("resizeactive 0 50"))
hl.bind("SUPER + CTRL + H", hl.dsp.window.resize({ x = -40, y = 0 }), { repeating = true })
hl.bind("SUPER + CTRL + L", hl.dsp.window.resize({ x = 40, y = 0 }), { repeating = true })
hl.bind("SUPER + CTRL + K", hl.dsp.window.resize({ x = 0, y = -40 }), { repeating = true })
hl.bind("SUPER + CTRL + J", hl.dsp.window.resize({ x = 0, y = 40 }), { repeating = true })

--------------
---- Zoom ----
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
hl.bind("SUPER + mouse_down", function() zoomfunction(-0.5) end, { repeating = true })
hl.bind("SUPER + mouse_up",   function() zoomfunction(0.5) end, { repeating = true })
hl.bind("SUPER + code:82",    function() zoomfunction(-0.3) end, { repeating = true })
hl.bind("SUPER + code:86",    function() zoomfunction(0.3) end, { repeating = true })

--------------------
---- Media/keys ----
--------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Exit dispatcher
hl.bind("SUPER + SHIFT + E", hl.dsp.exit())
