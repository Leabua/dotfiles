return {
	"HiPhish/rainbow-delimiters.nvim",
	-- 'init' runs BEFORE the plugin is loaded, ensuring Neovim reads the variables
	init = function()
		vim.g.rainbow_delimiters = {
			highlight = {
				"RainbowDelimiterViolet",
				"RainbowDelimiterBlue",
				"RainbowDelimiterGreen",
				"RainbowDelimiterOrange",
				"RainbowDelimiterYellow",
				"RainbowDelimiterCyan",
			},
		}
	end,
}
