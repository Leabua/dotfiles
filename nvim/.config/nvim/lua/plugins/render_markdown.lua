return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"echasnovski/mini.icons",
	},
	ft = { "markdown" },
	opts = {
		code = {
			style = "none", -- This strictly forbids the plugin from painting grey boxes
		},
	},
}
