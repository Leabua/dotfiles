local augroup = vim.api.nvim_create_augroup("snacks_dashboard_clean", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = "snacks_dashboard",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
		vim.opt_local.statuscolumn = ""
		vim.opt_local.foldcolumn = "0"
		vim.opt_local.cursorline = false
	end,
})

-- Automatically make <Esc> close any floating windows (like LSP hover)
vim.api.nvim_create_autocmd("WinEnter", {
	desc = "Close floating windows with Escape",
	callback = function()
		-- Check if the current window is a float
		local win_config = vim.api.nvim_win_get_config(0)
		if win_config.relative ~= "" then
			-- Map <Esc> to close it buffer-locally
			vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = true, silent = true })
		end
	end,
})

-- Highlight on yank/delete
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	desc = "Briefly highlight yanked or deleted text",
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
	end,
})
-- tell qml files to just use 4 tabs
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qml" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.expandtab = true
	end,
})
