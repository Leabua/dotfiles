return {
	"stevearc/oil.nvim",
	dependencies = {
		{ "echasnovski/mini.icons", lazy = false },
		{ "nvim-tree/nvim-web-devicons" },
	},
	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open Parent Directory" },
	},
	config = function()
		local oil = require("oil")
		oil.setup({
			keymaps = {
				["h"] = "actions.parent",
				["l"] = "actions.select",
			},
		})
	end,
}
