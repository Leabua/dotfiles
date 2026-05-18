return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000, -- Load this first
	config = function()
		require("catppuccin").setup({
			flavour = "mocha", -- Your established preference
			transparent_background = true, -- Matches your minimalist/transparent Arch aesthetic
			term_colors = true,
			integrations = {
				cmp = true,
				gitsigns = true,
				nvimtree = true,
				treesitter = true,
				notify = true,
				rainbow_delimiters = true, -- Fixes the bracket issue automatically
				mini = {
					enabled = true,
					indentscope_color = "",
				},
				-- Matches your focus on LSP/Data Science workflow
				native_lsp = {
					enabled = true,
					virtual_text = {
						errors = { "italic" },
						hints = { "italic" },
						warnings = { "italic" },
						information = { "italic" },
					},
					underlines = {
						errors = { "undercurl" },
						hints = { "undercurl" },
						warnings = { "undercurl" },
						information = { "undercurl" },
					},
				},
			},
		})

		-- Set the colorscheme
		vim.cmd.colorscheme("catppuccin-mocha")
	end,
}
