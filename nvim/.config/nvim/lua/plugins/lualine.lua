return {
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			opts.options = opts.options or {}
			opts.options.globalstatus = true

			-- Load the Dracula theme explicitly
			local theme = require("lualine.themes.dracula")

			-- Apply transparency to the 'c' section (the middle part) for all modes
			local modes = { "normal", "insert", "visual", "command", "replace", "inactive" }
			for _, mode in ipairs(modes) do
				if theme[mode] and theme[mode].c then
					theme[mode].c.bg = "none"
				end
			end

			opts.options.theme = theme
			return opts
		end,
		config = function(_, opts)
			require("lualine").setup(opts)

			-- Force highlights to remain transparent at the Neovim level
			local groups = {
				"StatusLine",
				"StatusLineNC",
				"lualine_transparent",
				"lualine_c_normal",
				"lualine_c_insert",
				"lualine_c_visual",
				"lualine_c_command",
				"lualine_c_inactive",
			}

			for _, group in ipairs(groups) do
				vim.api.nvim_set_hl(0, group, { bg = "none" })
			end
		end,
	},
}
