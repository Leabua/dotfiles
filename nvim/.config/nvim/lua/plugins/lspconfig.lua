return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- mason first: its setup puts ~/.local/share/nvim/mason/bin on nvim's PATH,
		-- which is where vim.lsp.enable and conform look for binaries
		{ "mason-org/mason.nvim", cmd = "Mason", opts = {} },
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
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

		local servers = {
			"basedpyright",
			"clangd",
			"cssls",
			"gopls",
			"html",
			"lua_ls",
			"rust_analyzer",
			"tailwindcss",
			"ts_ls",
		}

		-- formatters conform.lua calls; rustfmt comes from rustup, not Mason
		local tools = { "prettier", "stylua", "black", "shfmt" }

		-- Mason installs anything missing in the background (:Mason to watch / manage).
		-- automatic_enable is off because the vim.lsp.enable call below owns that list.
		require("mason-lspconfig").setup({ automatic_enable = false })
		require("mason-tool-installer").setup({
			ensure_installed = vim.list_extend(vim.deepcopy(servers), tools),
		})
		-- it only checks on VimEnter; this plugin loads on the first buffer read,
		-- which can come after that (opening nvim empty, then a file), so kick it here
		if vim.v.vim_did_enter == 1 then
			require("mason-tool-installer").run_on_start()
		end

		vim.lsp.config("rust_analyzer", {
			settings = {
				["rust-analyzer"] = {
					check = { command = "clippy" },
				},
			},
		})

		vim.lsp.enable(servers)

		-- Window id of the last combined K float, so a second K enters it.
		local k_float_win = nil
		local k_float_buf = nil

		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP keymaps",
			callback = function(event)
				local map = function(keys, fn, desc)
					vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				map("gd", vim.lsp.buf.definition, "Goto definition")
				map("<leader>rn", vim.lsp.buf.rename, "Rename")
				map("<leader>ca", vim.lsp.buf.code_action, "Code action")

				-- K shows BOTH the diagnostic (error/warning) and hover docs in one
				-- popup. Press K again to enter the float; q or <Esc> closes it.

				map("K", function()
					if
						k_float_win
						and vim.api.nvim_win_is_valid(k_float_win)
						and vim.api.nvim_get_current_buf() == k_float_buf
					then
						vim.api.nvim_set_current_win(k_float_win)
						return
					end

					local bufnr = event.buf
					local line = vim.fn.line(".") - 1
					local col = vim.fn.col(".") - 1
					local at_cursor = {}
					for _, d in ipairs(vim.diagnostic.get(bufnr, { lnum = line })) do
						-- End positions are exclusive; point diagnostics still match their cursor position.
						if
							(line ~= d.lnum or col >= d.col)
							and (
								line ~= d.end_lnum
								or col < d.end_col
								or (d.lnum == d.end_lnum and d.col == d.end_col and col == d.col)
							)
						then
							table.insert(at_cursor, d)
						end
					end

					if #at_cursor == 0 then
						vim.lsp.buf.hover({ border = "rounded" })
						return
					end

					local diag_lines = {}
					for _, d in ipairs(at_cursor) do
						local sev = vim.diagnostic.severity[d.severity] or "ERROR"
						sev = sev:sub(1, 1) .. sev:sub(2):lower()
						local src = d.source and (" [" .. d.source .. "]") or ""
						for _, msg_line in ipairs(vim.split(d.message or "", "\n", { plain = true })) do
							table.insert(diag_lines, string.format("- **%s**%s: %s", sev, src, msg_line))
						end
					end

					local params = function(client)
						return vim.lsp.util.make_position_params(0, client.offset_encoding)
					end
					vim.lsp.buf_request_all(bufnr, "textDocument/hover", params, function(results)
						local hover_lines = {}
						for _, res in pairs(results or {}) do
							if res.result and res.result.contents then
								local lines = vim.lsp.util.convert_input_to_markdown_lines(res.result.contents)
								lines = vim.lsp.util.trim_empty_lines(lines) or {}
								if #lines > 0 then
									vim.list_extend(hover_lines, lines)
								end
							end
						end

						local lines = vim.deepcopy(diag_lines)
						if #hover_lines > 0 then
							table.insert(lines, "")
							table.insert(lines, "---")
							table.insert(lines, "")
							vim.list_extend(lines, hover_lines)
						end

						local _, win = vim.lsp.util.open_floating_preview(lines, "markdown", {
							border = "rounded",
							focus = false,
							focusable = true,
							max_width = 80,
							max_height = 30,
							wrap = true,
						})
						k_float_win = win
						k_float_buf = bufnr
					end)
				end, "Hover docs + diagnostic (K again to enter, q/Esc to close)")
			end,
		})
	end,
}
