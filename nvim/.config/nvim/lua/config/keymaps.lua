-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- The format is vim.keymap.set("mode", "bind", "what vim must do")
-- This remap is purely so i can move things up and down using the move command (:m) - @thePrimeagen
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- capital J for shift
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv") -- capital K for shift

-- Half page jumping with cursor in the same place
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- when using "/" to search this keeps the search term in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- This is to stop vim adding replaced text into clipboard
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Pressing 'K' in insert mode will show signature help
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })
