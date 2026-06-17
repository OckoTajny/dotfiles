---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    colorscheme = "astrodark",
    highlights = {
      init = {
        Normal = { bg = "NONE" },
        NormalNC = { bg = "NONE" },
        NormalFloat = { bg = "NONE" },
        FloatBorder = { bg = "NONE" },
        SignColumn = { bg = "NONE" },
        StatusLine = { bg = "NONE" },
        StatusLineNC = { bg = "NONE" },
      },
      astrodark = {
        Normal = { bg = "NONE" },
        NormalNC = { bg = "NONE" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
