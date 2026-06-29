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
		opts = function()
			local theme = require("lualine.themes.seoul256")
			-- local theme = require("lualine.themes.palenight")
			for _, mode in pairs(theme) do
				if mode.b then
					mode.b.bg = "NONE"
				end
				if mode.c then
					mode.c.bg = "NONE"
				end
			end
			return {
				options = {
					theme = theme,
					section_separators = { left = "\u{e0b1}", right = "\u{e0b3}" },
				},
				sections = {
					-- keep the filled triangle caps on the coloured end sections
					lualine_a = { { "mode", separator = { right = "\u{e0b0}" } } },
					lualine_z = { { "location", separator = { left = "\u{e0b2}" } } },
				},
			}
		end,
	},
}
