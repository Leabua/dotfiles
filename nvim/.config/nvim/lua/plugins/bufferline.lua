return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "VeryLazy",
	keys = {
		{ "H", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
		{ "L", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		{ "<leader>bd", "<cmd>bdelete<cr>", desc = "Close Buffer" },
	},
	opts = {
		options = {
			always_show_bufferline = true,
			show_buffer_close_icons = false,
			show_close_icon = false,

			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(count, level)
				local icon = level:match("error") and " " or " "
				return " " .. icon .. count
			end,

			offsets = {
				{
					filetype = "oil",
					text = "File Explorer",
					highlight = "Directory",
					text_align = "left",
				},
			},
		},
		highlights = {
			fill = { bg = "NONE" },
			background = { bg = "NONE" },
			separator = { bg = "NONE" },
		},
	},
}
