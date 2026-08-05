-- Extra environment variables
-- https://wiki.hyprland.org/Configuring/Environment-variables/

local home = os.getenv("HOME")

-- Input method — see https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
-- hl.env("QT_IM_MODULE", "fcitx")
-- hl.env("XMODIFIERS", "@im=fcitx")
-- hl.env("SDL_IM_MODULE", "fcitx")
-- hl.env("GLFW_IM_MODULE", "ibus")
-- hl.env("INPUT_METHOD", "fcitx")

-- Wayland
-- hl.env("WLR_DRM_NO_ATOMIC", "1")       -- tearing
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- Editor — https://wiki.archlinux.org/title/Category:Text_editors
-- hl.env("EDITOR", "vim")

-- ~/.local/bin ahead of /usr/local/bin so the autostarted `ambxst` resolves to
-- the guard wrapper (~/.local/bin/ambxst -> systemctl start ambxst.service,
-- idempotent = single instance) instead of the raw /usr/local/bin/ambxst that
-- races the service and double-spawns the shell.
hl.env("PATH", home .. "/.local/bin:" .. os.getenv("PATH"))
