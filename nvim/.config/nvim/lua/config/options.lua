-- leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- vim.opt.guicursor = "n-v-c-i:block"
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.wrap = false

-- global clipboard
vim.opt.clipboard = "unnamedplus"

-- auto reload config
vim.opt.autoread = true

vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.fillchars = { eob = " " }

vim.opt.number = true -- Show absolute line number of the current line
vim.opt.relativenumber = true -- Show relative numbers for all other lines
vim.opt.scrolloff = 8

if vim.fn.executable("./.venv/bin/python") == 1 then
	vim.g.python3_host_prog = "./.venv/bin/python"
end

vim.opt.termguicolors = true -- Enables 24-bit RGB color
vim.opt.cursorline = true -- Highlights the current line (great for Master layout)
vim.opt.laststatus = 3 -- Global statusline (looks much cleaner on modern rices)
vim.opt.swapfile = false

vim.cmd.colorscheme("zednight")
