local opt = vim.opt

-- UI settings
opt.cursorline = true
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"  -- Always show sign column for diagnostics
opt.showmode = false    -- Mode is shown in the status line

-- Indentation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- File handling
opt.swapfile = false
opt.backup = false
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
opt.undofile = true

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Editor behavior
opt.wrap = false
opt.scrolloff = 8      -- Keep 8 lines above/below cursor when scrolling
opt.sidescrolloff = 8  -- Keep 8 columns left/right of cursor when scrolling horizontally
opt.updatetime = 50    -- Faster update time for better UX

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- replace ~ with the new character
vim.opt.fillchars = {eob = "-"}

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
