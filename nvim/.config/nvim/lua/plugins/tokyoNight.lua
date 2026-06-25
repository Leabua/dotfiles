return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,

		opts = {
			style = "night",
			transparent = true,

			on_highlights = function(hl, c)
				-- Core UI
				hl.Normal = { bg = "NONE" }
				hl.NormalNC = { bg = "NONE" }
				hl.NormalFloat = { bg = "NONE" }
				hl.FloatTitle = { bg = "NONE" }
				hl.FloatBorder = { bg = "NONE" }
				hl.SignColumn = { bg = "NONE" }
				hl.EndOfBuffer = { bg = "NONE" }

				-- Popup menus
				hl.Pmenu = { bg = "NONE" }

				-- Snacks
				hl.SnacksNormal = { bg = "NONE" }
				hl.SnacksPicker = { bg = "NONE" }
				hl.SnacksPickerBorder = { bg = "NONE" }
				hl.SnacksPickerInput = { bg = "NONE" }
				hl.SnacksPickerInputBorder = { bg = "NONE" }
				hl.SnacksPickerPreview = { bg = "NONE" }
				hl.SnacksPickerPreviewBorder = { bg = "NONE" }
				hl.SnacksDashboardHeader = { fg = c.teal }
				hl.Directory = { fg = c.blue, bg = "NONE" }

				-- Header labels
				hl.SnacksPickerTitle = {
					fg = c.blue,
					bg = "NONE",
				}

				hl.SnacksPickerKey = {
					fg = c.blue,
					bg = "NONE",
				}
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

				"SnacksNormal",
				"SnacksPicker",
				"SnacksPickerBorder",
				"SnacksPickerInput",
				"SnacksPickerInputBorder",
				"SnacksPickerPreview",
				"SnacksPickerPreviewBorder",

				"SnacksPickerTitle",
				"SnacksPickerKey",
			}

			for _, group in ipairs(transparent_groups) do
				vim.api.nvim_set_hl(0, group, { bg = "NONE" })
			end
		end,
	},
}
