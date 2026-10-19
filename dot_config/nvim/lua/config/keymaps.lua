-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- "Normal editor" controls on top of vim: Ctrl+C/X/V clipboard, Ctrl+Z/Y undo/redo,
-- Ctrl+A select all, Shift+arrows / mouse select (see options.lua). Visual block moved to Ctrl+Q.
local map = vim.keymap.set

-- copy / cut: selection, or the whole line when nothing is selected
map("x", "<C-c>", '"+y', { desc = "Copy" })
map("s", "<C-c>", '<C-g>"+y', { desc = "Copy" })
map("n", "<C-c>", '"+yy', { desc = "Copy line" })
map("x", "<C-x>", '"+d', { desc = "Cut" })
map("s", "<C-x>", '<C-g>"+d', { desc = "Cut" })
map("n", "<C-x>", '"+dd', { desc = "Cut line" })

-- paste (replaces the selection)
map("n", "<C-v>", '"+P', { desc = "Paste" })
map("x", "<C-v>", '"+P', { desc = "Paste over selection" })
map("s", "<C-v>", '<C-g>"+P', { desc = "Paste over selection" })
map({ "i", "c" }, "<C-v>", "<C-r><C-o>+", { desc = "Paste" })
map("n", "<C-q>", "<C-v>", { desc = "Visual block (was Ctrl+V)" })

-- undo / redo
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
map("n", "<C-y>", "<C-r>", { desc = "Redo" })

-- select all
map("n", "<C-a>", "gg0vG$", { desc = "Select all" })
map("x", "<C-a>", "<Esc>gg0vG$", { desc = "Select all" })
map("i", "<C-a>", "<Esc>gg0vG$", { desc = "Select all" })

-- typing over a Shift/mouse selection replaces it, Backspace deletes it (select mode does this);
-- Tab/Shift+Tab indent a visual selection
map("x", "<Tab>", ">gv", { desc = "Indent" })
map("x", "<S-Tab>", "<gv", { desc = "Outdent" })
