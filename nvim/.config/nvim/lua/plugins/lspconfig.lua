-- Find an already-open, focusable preview float (our hover / diagnostic popup).
local function find_preview_float()
	local cur = vim.api.nvim_get_current_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if win ~= cur then
			local cfg = vim.api.nvim_win_get_config(win)
			if cfg.relative ~= "" and cfg.focusable then
				return win
			end
		end
	end
end

-- Jump into a float and make <Esc> close it (q also works, via the built-in map).
local function enter_float(win)
	vim.api.nvim_set_current_win(win)
	local buf = vim.api.nvim_win_get_buf(win)
	vim.keymap.set("n", "<Esc>", function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end, { buffer = buf, nowait = true, desc = "Close float" })
end

-- Is the cursor sitting on top of a diagnostic span?
local function cursor_on_diagnostic(bufnr)
	local lnum = vim.fn.line(".") - 1
	local col = vim.fn.col(".") - 1
	for _, d in ipairs(vim.diagnostic.get(bufnr, { lnum = lnum })) do
		if col >= d.col and col <= d.end_col then
			return true
		end
	end
	return false
end

-- K: open LSP doc or diagnostic (depending on the cursor). K again: jump into it.
local function hover_or_diagnostic(bufnr)
	local existing = find_preview_float()
	if existing then
		enter_float(existing)
		return
	end

	if cursor_on_diagnostic(bufnr) then
		vim.diagnostic.open_float({
			scope = "cursor",
			border = "rounded",
			focusable = true,
			close_events = { "InsertEnter", "BufLeave" },
		})
	else
		vim.lsp.buf.hover({
			border = "rounded",
			close_events = { "InsertEnter", "BufLeave" },
		})
	end
end

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
					hover_or_diagnostic(event.buf)
				end, "Hover / diagnostic (K again to enter, Esc to close)")
			end,
		})
	end,
}
