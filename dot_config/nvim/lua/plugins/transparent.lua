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
        c.fg = "#d0d6e0"
        c.fg_dark = "#9da5b4"
        c.fg_gutter = "#495162"
        c.comment = "#5c6370"
        c.dark3 = "#495162"
        c.dark5 = "#7f848e"
        c.terminal_black = "#2d3139"
        c.blue = "#00a8ff"
        c.blue0 = "#2c313a"
        c.blue1 = "#00e5ff"
        c.blue2 = "#00e5ff"
        c.blue5 = "#00a8ff"
        c.blue6 = "#6fd0ff"
        c.blue7 = "#2c313a"
        c.cyan = "#00e5ff"
        c.teal = "#00e5ff"
        c.green = "#3dff7a"
        c.green1 = "#00e5ff"
        c.green2 = "#3dff7a"
        c.magenta = "#f03cff"
        c.magenta2 = "#f03cff"
        c.purple = "#f03cff"
        c.red = "#ff2e56"
        c.red1 = "#ff2e56"
        c.orange = "#ff8c1a"
        c.yellow = "#ffd23f"
        c.error = "#ff2e56"
        c.warning = "#ffd23f"
        c.info = "#00a8ff"
        c.hint = "#00e5ff"
        c.git = { add = "#3dff7a", change = "#00a8ff", delete = "#ff2e56", ignore = "#5c6370" }
      end or nil,
      on_highlights = i3 and function(hl)
        -- syntax, matching the VS Code Hyper token colors
        local fg = function(c, extra) return vim.tbl_extend("force", { fg = c }, extra or {}) end
        for group, spec in pairs({
          Keyword = fg("#f03cff"), ["@keyword"] = fg("#f03cff"), ["@keyword.function"] = fg("#f03cff"),
          ["@keyword.return"] = fg("#f03cff"), ["@keyword.import"] = fg("#f03cff"), ["@conditional"] = fg("#f03cff"),
          ["@variable"] = fg("#ff2e56"), ["@variable.member"] = fg("#ff2e56"), ["@property"] = fg("#ff2e56"),
          ["@variable.parameter"] = fg("#a6b2c0"), ["@variable.builtin"] = fg("#ffd23f"),
          Function = fg("#00a8ff"), ["@function"] = fg("#00a8ff"), ["@function.call"] = fg("#00a8ff"),
          ["@function.method"] = fg("#00a8ff"), ["@function.method.call"] = fg("#00a8ff"), ["@constructor"] = fg("#ffd23f"),
          String = fg("#3dff7a"), ["@string"] = fg("#3dff7a"), ["@string.escape"] = fg("#00e5ff"),
          Number = fg("#ff8c1a"), ["@number"] = fg("#ff8c1a"), Boolean = fg("#ff8c1a"), ["@boolean"] = fg("#ff8c1a"),
          Constant = fg("#ffd23f"), ["@constant"] = fg("#ffd23f"), ["@constant.builtin"] = fg("#ff8c1a"),
          Type = fg("#ffd23f"), ["@type"] = fg("#ffd23f"), ["@type.builtin"] = fg("#ffd23f"), ["@module"] = fg("#ffd23f"),
          Operator = fg("#00e5ff"), ["@operator"] = fg("#00e5ff"), ["@punctuation.bracket"] = fg("#d0d6e0"),
          ["@punctuation.delimiter"] = fg("#d0d6e0"), ["@tag"] = fg("#ff2e56"), ["@tag.attribute"] = fg("#ff8c1a", { italic = true }),
          Comment = fg("#5c6370", { italic = true }), ["@comment"] = fg("#5c6370", { italic = true }),
          -- UI
          Cursor = { fg = "#000000", bg = "#14fa50" }, CursorLineNr = fg("#14fa50", { bold = true }),
          CursorLine = { bg = "#0d0f13" }, LineNr = fg("#495162"), Visual = { bg = "#0b3d70" },
          Search = { fg = "#000000", bg = "#ffd23f" }, IncSearch = { fg = "#000000", bg = "#14fa50" },
          CurSearch = { fg = "#000000", bg = "#14fa50" }, MatchParen = fg("#14fa50", { bold = true, underline = true }),
          WinSeparator = fg("#2c313a"), FloatBorder = fg("#00a8ff"), Pmenu = { fg = "#d0d6e0", bg = "#000000" },
          PmenuSel = { fg = "#000000", bg = "#00a8ff" }, PmenuThumb = { bg = "#00a8ff" },
          DiagnosticError = fg("#ff2e56"), DiagnosticWarn = fg("#ffd23f"), DiagnosticInfo = fg("#00a8ff"),
          DiagnosticHint = fg("#00e5ff"), DiagnosticUnderlineError = { undercurl = true, sp = "#ff2e56" },
          DiagnosticUnderlineWarn = { undercurl = true, sp = "#ffd23f" },
        }) do
          hl[group] = spec
        end
      end or nil,
    },
  },
}
