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
        c.error = "#ef596f"
        c.warning = "#e5c07b"
        c.info = "#52adf2"
        c.hint = "#2bbac5"
        c.git = { add = "#89ca78", change = "#52adf2", delete = "#ef596f", ignore = "#5c6370" }
      end or nil,
      on_highlights = i3 and function(hl)
        -- syntax, matching the VS Code Hyper token colors
        local fg = function(c, extra) return vim.tbl_extend("force", { fg = c }, extra or {}) end
        for group, spec in pairs({
          Keyword = fg("#d55fde"), ["@keyword"] = fg("#d55fde"), ["@keyword.function"] = fg("#d55fde"),
          ["@keyword.return"] = fg("#d55fde"), ["@keyword.import"] = fg("#d55fde"), ["@conditional"] = fg("#d55fde"),
          ["@variable"] = fg("#ef596f"), ["@variable.member"] = fg("#ef596f"), ["@property"] = fg("#ef596f"),
          ["@variable.parameter"] = fg("#a6b2c0"), ["@variable.builtin"] = fg("#e5c07b"),
          Function = fg("#52adf2"), ["@function"] = fg("#52adf2"), ["@function.call"] = fg("#52adf2"),
          ["@function.method"] = fg("#52adf2"), ["@function.method.call"] = fg("#52adf2"), ["@constructor"] = fg("#e5c07b"),
          String = fg("#89ca78"), ["@string"] = fg("#89ca78"), ["@string.escape"] = fg("#2bbac5"),
          Number = fg("#d8985f"), ["@number"] = fg("#d8985f"), Boolean = fg("#d8985f"), ["@boolean"] = fg("#d8985f"),
          Constant = fg("#e5c07b"), ["@constant"] = fg("#e5c07b"), ["@constant.builtin"] = fg("#d8985f"),
          Type = fg("#e5c07b"), ["@type"] = fg("#e5c07b"), ["@type.builtin"] = fg("#e5c07b"), ["@module"] = fg("#e5c07b"),
          Operator = fg("#2bbac5"), ["@operator"] = fg("#2bbac5"), ["@punctuation.bracket"] = fg("#abb2bf"),
          ["@punctuation.delimiter"] = fg("#abb2bf"), ["@tag"] = fg("#ef596f"), ["@tag.attribute"] = fg("#d8985f", { italic = true }),
          Comment = fg("#5c6370", { italic = true }), ["@comment"] = fg("#5c6370", { italic = true }),
          -- UI
          Cursor = { fg = "#000000", bg = "#14fa50" }, CursorLineNr = fg("#14fa50", { bold = true }),
          CursorLine = { bg = "#0d0f13" }, LineNr = fg("#495162"), Visual = { bg = "#2c3a52" },
          Search = { fg = "#000000", bg = "#e5c07b" }, IncSearch = { fg = "#000000", bg = "#14fa50" },
          CurSearch = { fg = "#000000", bg = "#14fa50" }, MatchParen = fg("#14fa50", { bold = true, underline = true }),
          WinSeparator = fg("#2c313a"), FloatBorder = fg("#52adf2"), Pmenu = { fg = "#abb2bf", bg = "#000000" },
          PmenuSel = { fg = "#000000", bg = "#52adf2" }, PmenuThumb = { bg = "#52adf2" },
          DiagnosticError = fg("#ef596f"), DiagnosticWarn = fg("#e5c07b"), DiagnosticInfo = fg("#52adf2"),
          DiagnosticHint = fg("#2bbac5"), DiagnosticUnderlineError = { undercurl = true, sp = "#ef596f" },
          DiagnosticUnderlineWarn = { undercurl = true, sp = "#e5c07b" },
        }) do
          hl[group] = spec
        end
      end or nil,
    },
  },
}
