return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,

		opts = {
			style = "night",
			transparent = true,

			styles = {
				keywords = {}, -- removes italic from keywords, comments keep their default italic
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

				-- Explorer header (bufferline offset uses this group)
				hl.Directory = { fg = c.blue, bg = "NONE" }

				-- Header labels (the real groups -- SnacksPickerTitle/SnacksPickerKey
				-- don't exist in tokyonight's source, they were a dead end)
				hl.SnacksPickerInputTitle = {
					fg = c.blue,
					bg = "NONE",
				}
				hl.SnacksPickerBoxTitle = {
					fg = c.blue,
					bg = "NONE",
				}
				-- The "h" toggle badge -- normally linked to SnacksProfilerBadgeInfo,
				-- overridden directly here to break that link and kill its background
				hl.SnacksPickerToggle = {
					fg = c.blue1,
					bg = "NONE",
				}
			end,
		},

		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")

			-- NOTE: SnacksPickerTitle and SnacksPickerKey are intentionally NOT in this
			-- list anymore. on_highlights already sets bg = "NONE" for them along with
			-- their fg color. nvim_set_hl() replaces a highlight's whole definition
			-- rather than merging into it, so including them here would wipe out the
			-- fg color set above.
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
			}

			for _, group in ipairs(transparent_groups) do
				vim.api.nvim_set_hl(0, group, { bg = "NONE" })
			end
		end,
	},
}
