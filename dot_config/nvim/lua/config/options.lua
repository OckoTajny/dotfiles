-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Shift+arrows / Shift+Home/End and mouse drags select like a normal editor (select mode:
-- typing replaces the selection). Keymaps for Ctrl+C/X/V etc. are in keymaps.lua.
vim.opt.keymodel = "startsel,stopsel"
vim.opt.selectmode = "mouse,key"
vim.opt.selection = "exclusive"
