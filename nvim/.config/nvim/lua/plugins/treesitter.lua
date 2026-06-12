return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		local status_ok, configs = pcall(require, "nvim-treesitter.configs")

		if not status_ok then
			return
		end

		configs.setup({
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"query",
				"javascript",
				"typescript",
				"python",
				"bash",
				"html",
				"css",
				"markdown", -- ADDED: Required for LSP hover popups
				"markdown_inline", -- ADDED: Required for code inside LSP popups
			},

			highlight = { enable = true },
			indent = { enable = true },
			sync_install = false,
			auto_install = true,
		})
	end,
}
