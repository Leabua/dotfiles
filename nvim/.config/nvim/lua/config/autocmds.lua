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
