return {
	"stevearc/oil.nvim",
	-- load at startup so oil can hijack netrw and handle `nvim <dir>`
	lazy = false,
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {},
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
	},
}
