return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "VeryLazy",
	keys = {
		{ "H", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "L", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "<leader>bd", "<cmd>bdelete<cr>", desc = "Close Buffer" },
		{ "<leader>bf", "<cmd>BufferLineCloseOthers<cr>", desc = "Close Other Buffers" },
	},
	opts = {
		options = {
			always_show_bufferline = true,
			show_buffer_close_icons = false,
			show_close_icon = false,

			-- Keeps the vertical separators hidden
			separator_style = { "", "" },

			indicator = {
				style = "underline",
			},

			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(count, level)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,

			offsets = {
				-- 1. The input box (This is usually what touches the top tabline!)
				{
					filetype = "snacks_picker_input",
					text = "Explorer",
					highlight = "Directory",
					text_align = "left",
				},
				-- 2. The main list
				{
					filetype = "snacks_picker_list",
					text = "Explorer",
					highlight = "Directory",
					text_align = "left",
				},
				-- 3. Catch-all for the explorer
				{
					filetype = "snacks_explorer",
					text = "Explorer",
					highlight = "Directory",
					text_align = "left",
				},
			},
		},
		highlights = {
			fill = { bg = "NONE" },
			background = { bg = "NONE" },

			separator = { fg = "NONE", bg = "NONE" },
			separator_selected = { fg = "NONE", bg = "NONE" },

			buffer_selected = {
				bg = "NONE",
				bold = true,
				italic = false,
			},

			indicator_selected = {
				bg = "NONE",
				fg = "#cba6f7", -- Catppuccin Mauve
				sp = "#cba6f7",
				underline = true,
			},
		},
	},
}
