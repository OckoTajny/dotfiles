-- Autostart
-- https://wiki.hyprland.org/Configuring/Keywords/#executing

local home = os.getenv("HOME")

hl.on("hyprland.start", function()
    -- Input method
    -- hl.exec_cmd("fcitx5")

    -- The Ambxst shell starts itself from ~/.local/share/ambxst/hyprland.lua
    -- (loaded by the root hyprland.lua). Don't add it here — duplicate shell.

    -- Ask about system updates on every boot (yes -> yay -Syu --noconfirm)
    hl.exec_cmd(home .. "/.local/bin/boot-update-prompt")
end)
