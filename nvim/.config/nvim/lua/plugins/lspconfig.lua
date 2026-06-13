return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		-- 1. Global Diagnostic Settings
		vim.diagnostic.config({
			signs = false,
			virtual_text = false, -- Disabled by default for clean code
			severity_sort = true,
			underline = true,
			update_in_insert = false,
			float = {
				border = "rounded", -- Adds borders to all diagnostic windows
				source = true,
			},
		})

		-- 2. Setup Package Managers
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

		-- 3. LSP Mappings and Behavior (Runs when an LSP connects to a file)
		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP Keybindings",
			callback = function(event)
				local map = vim.keymap.set
				local opts = { buffer = event.buf }

				-- Disable LSP semantic colors so Tree-sitter controls themes perfectly
				-- local client = vim.lsp.get_client_by_id(event.data.client_id)
				-- if client then
				-- 	client.server_capabilities.semanticTokensProvider = nil
				-- end

				-- Standard LSP actions
				map("n", "gd", vim.lsp.buf.definition, opts)
				map("n", "<leader>rn", vim.lsp.buf.rename, opts)
				map("n", "<leader>ca", vim.lsp.buf.code_action, opts)

				-- Smart K: Shows error if cursor is on one, otherwise shows docs
				map("n", "K", function()
					local line = vim.fn.line(".") - 1
					local col = vim.fn.col(".") - 1
					local diagnostics = vim.diagnostic.get(event.buf, { lnum = line })

					local on_diagnostic = false
					for _, d in ipairs(diagnostics) do
						if col >= d.col and col <= d.end_col then
							on_diagnostic = true
							break
						end
					end

					if on_diagnostic then
						vim.diagnostic.open_float({ border = "rounded", scope = "cursor" })
					else
						vim.lsp.buf.hover({ border = "rounded" })
					end
				end, opts)

				-- Modern Neovim 0.11 diagnostic jumping
				map("n", "<leader>[", function()
					vim.diagnostic.jump({ count = -1 })
				end, { buffer = event.buf, desc = "Previous Diagnostic" })

				map("n", "<leader>]", function()
					vim.diagnostic.jump({ count = 1 })
				end, { buffer = event.buf, desc = "Next Diagnostic" })

				-- Toggle inline virtual text on and off safely
				map("n", "<leader>tt", function()
					local current_config = vim.diagnostic.config() or {}
					local new_state = not current_config.virtual_text
					vim.diagnostic.config({ virtual_text = new_state })
					print("Virtual Text: " .. (new_state and "ON" or "OFF"))
				end, { buffer = event.buf, desc = "Toggle Virtual Text" })
			end,
		})

		-- 4. Native 0.11 Lua Server Configuration
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

		-- 5. Automatically enable all configured servers
		local servers = { "ts_ls", "html", "cssls", "lua_ls", "tailwindcss", "pyright" }
		for _, server in ipairs(servers) do
			vim.lsp.enable(server)
		end
	end,
}
