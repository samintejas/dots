local opt = vim.opt

opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
-- opt.colorcolumn = "80"



vim.g.mapleader = " "
vim.keymap.set("n","<leader>e",vim.cmd.Ex)
-- Copy to system clipboard
vim.keymap.set("v", "<leader>y", '"+y')  -- Copy in visual mode
vim.keymap.set("n", "<leader>Y", '"+yy') -- Copy the entire line

-- Paste from system clipboard
vim.keymap.set("n", "<leader>p", '"+p')  -- Paste after cursor
vim.keymap.set("n", "<leader>P", '"+P')  -- Paste before cursor
vim.keymap.set("v", "<leader>p", '"+p')  -- Paste in visual mode
