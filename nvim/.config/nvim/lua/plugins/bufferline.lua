return {
	"akinsho/bufferline.nvim",
	-- the real bufferline (snacks has no bufferline component). nvim-web-devicons
	-- is already pulled in by colors.lua, so buffer icons show up automatically.
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	keys = {
		-- move between buffers in the order shown in the bufferline
		{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
		{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
		-- layout-safe close: keeps window splits and the snacks explorer open
		{
			"<leader>bd",
			function()
				Snacks.bufdelete()
			end,
			desc = "Delete buffer",
		},
	},
	opts = function()
		local bufferline = require("bufferline")
		return {
			options = {
				-- indent the bufferline past the snacks explorer sidebar so the open
				-- buffers line up with the editor area, not over the file tree.
				offsets = {
					{
						filetype = "snacks_picker_list",
						text = "Snacks Explorer",
						text_align = "left",
						highlight = "Directory",
					},
				},
				diagnostics = "nvim_lsp",
				-- underline the active buffer instead of the default top/bottom bar
				indicator = { style = "underline" },
				-- no per-buffer close icon, no tabline-wide close icon
				show_buffer_close_icons = false,
				show_close_icon = false,
				style_preset = bufferline.style_preset.no_italic,
			},
			-- indicator.style = "underline" also underlines the tab/separator
			-- highlights next to the active buffer, which reads as one continuous
			-- horizontal line; keep the underline on the buffer name only.
			highlights = {
				separator_selected = { underline = false },
				tab_selected = { underline = false },
				indicator_selected = { underline = false },
			},
		}
	end,
}
