return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		formatters_by_ft = {
			javascript = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			javascriptreact = { "prettier" },
			json = { "prettier" },
			html = { "prettier" },
			css = { "prettier" },
			lua = { "stylua" },
			-- Added your installed Python and Bash formatters
			python = { "black" },
			sh = { "shfmt" },
		},
		format_on_save = {
			timeout_ms = 1500,
			lsp_fallback = true,
		},
	},
}
