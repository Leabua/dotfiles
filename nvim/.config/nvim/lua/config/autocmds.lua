-- autoread on buffer change
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	desc = "Reload file if changed on disk",
	command = "checktime",
})

-- Open stock netrw at the bottom when launching with a directory (`nvim .`)
vim.api.nvim_create_autocmd("VimEnter", {
	desc = "Open netrw in a bottom split for `nvim .`",
	callback = function()
		if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
			local dir = vim.fn.fnameescape(vim.fn.argv(0))
			vim.cmd("enew") -- replace the netrw directory buffer with an empty one
			vim.cmd("botright Sexplore " .. dir)
		end
	end,
})

-- Automatically make <Esc> close any floating windows (like LSP hover, oil)
vim.api.nvim_create_autocmd("WinEnter", {
	desc = "Close floating windows with Escape",
	callback = function()
		local win_config = vim.api.nvim_win_get_config(0)
		if win_config.relative ~= "" then
			vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = true, silent = true })
		end
	end,
})
