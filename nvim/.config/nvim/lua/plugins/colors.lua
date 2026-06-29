return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,

		opts = {
			style = "night",
			transparent = true,

			styles = {
				keywords = { italic = false }, -- removes italic from keywords; comments keep their default italic
			},

			on_highlights = function(hl, c)
				-- Core UI
				hl.Normal = { bg = "NONE" }
				hl.NormalNC = { bg = "NONE" }
				hl.NormalFloat = { bg = "NONE" }
				hl.FloatTitle = { bg = "NONE" }
				hl.FloatBorder = { bg = "NONE" }
				hl.SignColumn = { bg = "NONE" }
				hl.EndOfBuffer = { bg = "NONE" }
				hl.StatusLine = { bg = "NONE" }
				hl.StatusLineNC = { bg = "NONE" }

				-- Popup menus
				hl.Pmenu = { bg = "NONE" }

				-- Snacks dashboard
				hl.SnacksDashboardHeader = { fg = c.red }

				hl.Directory = { fg = c.blue, bg = "NONE" }
			end,
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")

			local transparent_groups = {
				"Normal",
				"NormalNC",
				"NormalFloat",
				"FloatBorder",
				"SignColumn",
				"EndOfBuffer",
			}

			for _, group in ipairs(transparent_groups) do
				vim.api.nvim_set_hl(0, group, { bg = "NONE" })
			end
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		opts = {},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			theme = "tokyonight",
		},
	},
}
