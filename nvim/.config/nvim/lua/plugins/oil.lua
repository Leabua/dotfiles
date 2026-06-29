return {
	"stevearc/oil.nvim",
	lazy = false,
	dependencies = {
		{ "echasnovski/mini.icons", lazy = false },
		{ "nvim-tree/nvim-web-devicons" },
	},
	keys = {
		{
			"<leader>e",
			function()
				require("oil").toggle_float()
			end,
			desc = "Toggle file explorer",
		},
	},
	config = function()
		require("oil").setup({
			skip_confirm_for_simple_edits = true,
			view_options = {
				show_hidden = true,
				is_hidden_file = function(name, _)
					return name:match("^%.") ~= nil
				end,
				natural_order = "fast",
				case_insensitive = true,
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},
			keymaps = {
				["h"] = "actions.parent",
				["l"] = "actions.select",
				["q"] = "actions.close",
			},
		})
	end,
}
