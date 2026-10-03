return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- slint-lsp comes from cargo (~/.cargo/bin), not Mason
        slint_lsp = { mason = false },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "slint" } },
  },
}
