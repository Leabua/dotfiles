return {
	"stevearc/oil.nvim",
	-- load at startup so oil can hijack netrw and handle `nvim <dir>`
	lazy = false,
	---@module 'oil'
	---@type oil.SetupOpts

	dependencies = { { "echasnovski/mini.icons", opts = {} } },

	opts = {
		view_options = {
			show_hidden = true,
		},
	},

	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
	},
}
