return {
	-- Better a/i text objects (function args, brackets, quotes, arguments, ...)
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		config = function()
			require("mini.ai").setup()
		end,
	},

	-- Autopairs (replaces nvim-autopairs)
	{
		"echasnovski/mini.pairs",
		event = "InsertEnter",
		config = function()
			require("mini.pairs").setup()
		end,
	},

	-- File explorer (replaces oil.nvim)
	{
		"echasnovski/mini.files",
		dependencies = { "echasnovski/mini.icons" },
		keys = {
			{
				"<leader>e",
				function()
					local mf = require("mini.files")
					-- toggle: close if already open, otherwise open at the current file
					if not mf.close() then
						local path = vim.api.nvim_buf_get_name(0)
						mf.open(path ~= "" and path or nil)
					end
				end,
				desc = "Toggle file explorer",
			},
		},
		config = function()
			require("mini.icons").setup()
			require("mini.files").setup({
				-- same keys oil used: h = parent, l = select/open, q = close
				mappings = {
					go_in = "l",
					go_in_plus = "L",
					go_out = "h",
					go_out_plus = "H",
					close = "q",
				},
				-- show dotfiles like oil did (show_hidden = true)
				content = {
					filter = function()
						return true
					end,
				},
				windows = {
					preview = true,
					width_preview = 25,
				},
			})

			-- <CR> opens the file (and closes the explorer), same as L.
			-- By default mini.files leaves <CR> as the plain "move down a line"
			-- motion, which is useless in the explorer.
			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					vim.keymap.set("n", "<CR>", function()
						require("mini.files").go_in({ close_on_file = true })
					end, { buffer = args.data.buf_id, desc = "Open file / enter directory" })
				end,
			})
		end,
	},
}
