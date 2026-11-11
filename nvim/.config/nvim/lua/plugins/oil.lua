return {
	"stevearc/oil.nvim",
	-- loads on `-`, :Oil, or the first time a directory buffer opens (`nvim .`, `:e dir`);
	-- oil's setup takes over the directory buffer it was loaded for
	cmd = "Oil",
	init = function()
		vim.g.loaded_netrw = 1 -- oil replaces netrw, so it must never grab a directory first
		vim.g.loaded_netrwPlugin = 1
		local function is_dir(path)
			local stat = path ~= "" and vim.uv.fs_stat(path)
			return stat and stat.type == "directory"
		end
		if vim.fn.argc() == 1 and is_dir(vim.fn.argv(0)) then
			require("lazy").load({ plugins = { "oil.nvim" } })
			return
		end
		vim.api.nvim_create_autocmd("BufEnter", {
			group = vim.api.nvim_create_augroup("OilLazyLoad", { clear = true }),
			callback = function(args)
				if is_dir(vim.api.nvim_buf_get_name(args.buf)) then
					require("lazy").load({ plugins = { "oil.nvim" } })
					return true -- delete this autocmd; oil handles directories from now on
				end
			end,
		})
	end,
	---@module 'oil'
	---@type oil.SetupOpts

	dependencies = { { "echasnovski/mini.icons", opts = {} } },

	opts = {
		view_options = {
			show_hidden = true,
		},
	},

	keys = {
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
	},
}
