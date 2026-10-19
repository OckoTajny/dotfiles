-- i3 session only: VS Code "Hyper" colors (same as ~/.config/i3). Elsewhere plain tokyonight.
local i3 = vim.env.XDG_CURRENT_DESKTOP == "i3"

return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      -- palette from the VS Code "Hyper" theme (alexlapwood.hyper-terminal-theme)
      on_colors = i3 and function(c)
        c.bg = "#000000"
        c.bg_dark = "#000000"
        c.bg_highlight = "#1a1d23"
        c.fg = "#abb2bf"
        c.fg_dark = "#9da5b4"
        c.fg_gutter = "#495162"
        c.comment = "#5c6370"
        c.dark3 = "#495162"
        c.dark5 = "#7f848e"
        c.terminal_black = "#2d3139"
        c.blue = "#52adf2"
        c.blue0 = "#2c313a"
        c.blue1 = "#2bbac5"
        c.blue2 = "#2bbac5"
        c.blue5 = "#52adf2"
        c.blue6 = "#8ed4ff"
        c.blue7 = "#2c313a"
        c.cyan = "#2bbac5"
        c.teal = "#2bbac5"
        c.green = "#89ca78"
        c.green1 = "#2bbac5"
        c.green2 = "#89ca78"
        c.magenta = "#d55fde"
        c.magenta2 = "#d55fde"
        c.purple = "#d55fde"
        c.red = "#ef596f"
        c.red1 = "#ef596f"
        c.orange = "#d8985f"
        c.yellow = "#e5c07b"
      end or nil,
      on_highlights = i3 and function(hl)
        hl.Cursor = { fg = "#000000", bg = "#14fa50" }
        hl.CursorLineNr = { fg = "#14fa50", bold = true }
        -- Hyper colors keywords magenta (cyan is for operators)
        hl.Keyword = { fg = "#d55fde" }
        hl["@keyword"] = { fg = "#d55fde" }
        hl["@keyword.function"] = { fg = "#d55fde" }
      end or nil,
    },
  },
}
