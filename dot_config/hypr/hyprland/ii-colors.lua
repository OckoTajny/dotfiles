-- Colours (illogical-impulse defaults, Lua port of hyprland/colors.conf).
-- Loaded after ii-general.lua, so these border colours win.
--
-- The upstream .conf also carried a `plugin { hyprbars { ... } }` block. The
-- hyprbars plugin is not installed here and Lua rejects unknown config keys
-- outright (unlike .conf, which ignored them), so that block is dropped.

hl.config({
    general = {
        col = {
            active_border   = "rgba(59413a77)",
            inactive_border = "rgba(26181433)",
        },
    },

    misc = {
        background_color = "rgba(1d100dFF)",
    },
})

hl.window_rule({ match = { pin = true }, border_color = "rgba(ffb59eAA) rgba(ffb59e77)" })
