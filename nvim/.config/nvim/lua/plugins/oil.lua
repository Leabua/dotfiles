return {
	"stevearc/oil.nvim",
	dependencies = {
		{ "echasnovski/mini.icons", lazy = false },
		{ "nvim-tree/nvim-web-devicons" },
	},
	config = function()
		local oil = require("oil")
		oil.setup({
			keymaps = {
				["h"] = "actions.parent",
				["l"] = "actions.select",
			},
		})
		vim.keymap.set("n", "-", oil.toggle_float, {})
	end,
	lazy = false,
}
