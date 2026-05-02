-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyLazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- The format is keymap.set("mode", "bind", "what vim must do")
local keymap = vim.keymap
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

-- Half page jumping with cursor in the same place
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- when using "/" to search this keeps the search term in the middle
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- This is to stop adding replaced text into clipboard
keymap.set("x", "<leader>p", '"_dP')

-- Pressing 'K' in insert mode will show signature help
keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

-- Delete a word backwards
keymap.set("i", "<C-h>", "<C-w>")
keymap.set("n", "<C-h>", "bdw")
