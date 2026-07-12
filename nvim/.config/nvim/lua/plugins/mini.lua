return {
	-- Better a/i text objects (function args, brackets, quotes, arguments, ...)
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		config = function()
			require("mini.ai").setup()
		end,
	},

	-- Autopairs (replaces nvim-autopairs)
	{
		"echasnovski/mini.pairs",
		event = "InsertEnter",
		config = function()
			require("mini.pairs").setup()
		end,
	},

	-- Minimal bufferline showing open buffers in the tabline
	{
		"echasnovski/mini.tabline",
		event = "VeryLazy",
		config = function()
			require("mini.tabline").setup()
		end,
	},
}
