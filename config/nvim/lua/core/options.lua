-- Leader Key
vim.keymap.set('', '<Space>', '<Nop>')
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Turn off builtin plugins I do not use
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1

-- Cursor
-- vim.opt.guicursor = 'i:block-blinkwait175-blinkoff150-blinkon175'

-- Colors
vim.opt.termguicolors = true
vim.opt.colorcolumn = "100"

-- Line Numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Default tab settings
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

-- Don't Wrap
vim.opt.wrap = false

-- Persistent undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. "/.local/state/nvim/undo"
vim.opt.undofile = true

-- Search
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Update time
vim.opt.updatetime = 250

