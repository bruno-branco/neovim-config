--mapleader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

--cursor
vim.opt.guicursor = "n-v-c-sm:block,i:blinkwait1-blinkon500-blinkoff20"
vim.opt.cursorline = true

--indenting
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

--splitting
vim.opt.splitright = true

--line numbers
vim.opt.number = true
vim.opt.relativenumber = true

--hlsearch and incsearch
vim.opt.hlsearch = false
vim.opt.incsearch = true

--colors
vim.opt.termguicolors = true

--update time
vim.opt.updatetime = 50

--color column
--vim.opt.colorcolumn = "40"

--copy to clipboard
vim.opt.clipboard = "unnamedplus"

--terminal hidden
vim.o.hidden = true
