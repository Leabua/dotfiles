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

--- Press <leader>d to see the full error in a pop-up
keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- Disable the command-line window (q: and q?)
vim.keymap.set("n", "q:", ":", { noremap = true })
vim.keymap.set("n", "q?", ":", { noremap = true })

-- Also disable the visual command-line window
vim.keymap.set("v", "q:", ":", { noremap = true })

-- Toggle diagnostics
keymap.set("n", "<leader>ud", function()
	local enabled = vim.diagnostic.is_enabled()
	vim.diagnostic.enable(not enabled)
	vim.notify(enabled and "Diagnostics disabled" or "Diagnostics enabled")
end, { desc = "Toggle Diagnostics" })
