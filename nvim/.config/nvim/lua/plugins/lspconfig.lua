return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"mason-org/mason-lspconfig.nvim",
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

		-- Quickshell / QML server (qmlls6) is DISABLED. On this quickshell project
		-- it balloons past 7GB (its .qmlls.ini lists /usr/bin in importPaths),
		-- which triggered the kernel OOM-killer and took down the whole terminal.
		-- To re-enable it *safely*, run it under a memory-capped systemd scope so a
		-- runaway qmlls kills only itself, never the editor/terminal:
		--
		--   vim.lsp.config("qmlls", {
		--     cmd = {
		--       "systemd-run", "--user", "--scope", "--quiet",
		--       "-p", "MemoryMax=2G", "-p", "MemorySwapMax=0",
		--       "/usr/sbin/qmlls6",
		--     },
		--     filetypes = { "qml", "qmljs" },
		--     root_markers = { { ".qmlls.ini", "shell.qml" }, ".git" },
		--   })
		--   vim.lsp.enable("qmlls")
		--
		-- Explicitly keep it off so nvim-lspconfig's built-in default can never
		-- auto-attach an uncapped qmlls and OOM the machine.
		vim.lsp.enable("qmlls", false)

		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls",
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"pyright",
			},
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

				map("K", function()
					local lnum = vim.fn.line(".") - 1
					local col = vim.fn.col(".") - 1
					local on_error = false
					for _, d in ipairs(vim.diagnostic.get(event.buf, { lnum = lnum })) do
						if col >= d.col and col <= d.end_col then
							on_error = true
							break
						end
					end

					if on_error then
						vim.diagnostic.open_float({ scope = "cursor", close_events = { "InsertEnter", "BufLeave" } })
						vim.lsp.buf.definition()
					else
						vim.lsp.buf.hover({ border = "rounded" })
					end
				end, "Hover / error + definition")
			end,
		})
	end,
}
