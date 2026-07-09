return {
	"stevearc/oil.nvim",
	-- load at startup so oil can hijack netrw and handle `nvim <dir>`
	lazy = false,
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		-- show dotfiles by default (toggle in oil with `g.`)
		view_options = {
			show_hidden = true,
		},
	},
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
	},
}
