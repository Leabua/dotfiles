return {
	-- Better a/i text objects
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		config = function()
			local ai = require("mini.ai")
			local gen_spec = ai.gen_spec

			ai.setup({
				custom_textobjects = {
					-- Maps 'F' to the entire function definition via Treesitter
					F = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
				},
			})
		end,
	},

	-- Autopairs (replaces nvim-autopairs)
	{
		"echasnovski/mini.pairs",
		event = "InsertEnter",
		config = function()
			require("mini.pairs").setup({
				map_cr = true,
			})
		end,
	},
}
