return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
	},
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					workspace = { checkThirdParty = false },
					telemetry = { enabled = false },
				},
			},
		})

		vim.lsp.config("basedpyright", {
			settings = {
				basedpyright = {
					analysis = {
						-- "basic" stops flagging unannotated {} / [] (e.g. `bucket = {}`)
						-- as errors while keeping real errors like undefined names.
						typeCheckingMode = "basic",
						diagnosticMode = "openFilesOnly",
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						autoImportCompletions = true,
					},
				},
			},
		})

		-- Servers come from Nix (environment.systemPackages), NOT Mason:
		-- Mason ships generic-linux binaries that NixOS can't exec. vim.lsp.enable
		-- just turns on lspconfig's built-in defaults; each starts only if its
		-- binary is on PATH, so installing it in configuration.nix is what wires
		-- it up. Add/remove a name here to match what you install via Nix.

		vim.lsp.enable({
			"basedpyright",
			"clangd",
			"cssls",
			"gopls",
			"html",
			"jdtls",
			"lua_ls",
			"tailwindcss",
			"ts_ls",
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP keymaps",
			callback = function(event)
				local map = function(keys, fn, desc)
					vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("gd", vim.lsp.buf.definition, "Goto definition")
				map("<leader>rn", vim.lsp.buf.rename, "Rename")
				map("<leader>ca", vim.lsp.buf.code_action, "Code action")

				-- K always shows hover docs. Diagnostics already have their own keys:
				-- <leader>d (line float), <leader>[ / <leader>] (jump + auto-float).
				-- (The old "smart K" showed the diagnostic instead of docs whenever
				-- the cursor sat on an error, hiding signatures like list.append().
				-- Press K again to enter the float; q or <Esc> closes it.)
				map("K", function()
					vim.lsp.buf.hover({ border = "rounded" })
				end, "Hover docs (K again to enter, q/Esc to close)")
			end,
		})
	end,
}
