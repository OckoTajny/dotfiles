-- Monitor layout. The hl.monitor / hl.workspace_rule lines below are rewritten
-- by ~/.local/bin/set-primary-monitor (Super+Shift+M); comments are preserved.
--
-- Primary monitor sits at 0x0, the others are laid out beside it and centred on
-- its other axis. Workspace 1 follows the primary rather than being pinned to a
-- monitor name, so a machine without that output doesn't boot onto workspace 2.
hl.monitor({ output = "DP-2", mode = "2560x1440@180", position = "0x0", scale = 1.0 })
hl.monitor({ output = "DP-1", mode = "1920x1080@165", position = "2560x180", scale = 1.0 })
hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x0", scale = 1.0 })
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })
