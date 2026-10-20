-- show LSP errors live while typing (like VS Code), not only after leaving insert mode
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        update_in_insert = true,
      },
    },
  },
}
