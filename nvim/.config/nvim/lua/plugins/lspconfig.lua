return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		-- 1. Configure Diagnostics (Useful inline info)
		vim.diagnostic.config({
			signs = false,
			virtual_text = {
				spacing = 4,
				prefix = "●",
				source = "if_many",
			},
			severity_sort = true,
			underline = true,
			update_in_insert = false,
		})

		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"ts_ls",
				"html",
				"cssls",
				"lua_ls",
				"tailwindcss",
				"pyright",
			},
		})

		-- 2. LSP keymaps using native LspAttach
		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP Keybindings",
			callback = function(event)
				local map = vim.keymap.set
				local opts = { buffer = event.buf }
				map("n", "gd", vim.lsp.buf.definition, opts)
				map("n", "K", vim.lsp.buf.hover, opts)
				map("n", "<leader>rn", vim.lsp.buf.rename, opts)
				map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
			end,
		})

		-- 3. The 0.11 Way: Configure lua_ls settings without using require('lspconfig')
		-- We inject the settings into the global LSP config table for lua_ls
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim", "Snacks" },
					},
					workspace = {
						checkThirdParty = false,
						library = vim.api.nvim_get_runtime_file("", true),
					},
					telemetry = { enabled = false },
				},
			},
		})

		-- 4. Enable all servers using the 0.11 native API
		local servers = { "ts_ls", "html", "cssls", "lua_ls", "tailwindcss", "pyright" }
		for _, server in ipairs(servers) do
			vim.lsp.enable(server)
		end
	end,
}
