-- autoread on buffer change
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
	desc = "Reload file if changed on disk",
	command = "checktime",
})
