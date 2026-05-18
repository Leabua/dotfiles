return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		-- 1. Safely try to load the module
		local status_ok, configs = pcall(require, "nvim-treesitter.configs")

		-- 2. If it's not installed/downloaded yet, silently abort the setup
		if not status_ok then
			return
		end

		-- 3. If it is installed, proceed as normal
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
			},
			highlight = { enable = true },
			indent = { enable = true },
			sync_install = false,
			auto_install = true,
		})
	end,
}
