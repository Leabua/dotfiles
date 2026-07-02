return {
	{
		-- auto-close and auto-rename HTML/JSX/TSX tags:
		--   typing `<div>` inserts the matching `</div>`, and renaming one
		--   side of a pair updates the other.
		"windwp/nvim-ts-autotag",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		ft = {
			"html",
			"xml",
			"javascript",
			"javascriptreact",
			"jsx",
			"typescript",
			"typescriptreact",
			"tsx",
			"markdown",
		},
		opts = {
			opts = {
				enable_close = true, -- auto-close tags
				enable_rename = true, -- keep the pair in sync when you edit one side
				enable_close_on_slash = false,
			},
		},
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			-- Filled vertical bars in the gutter (no letters). Colour carries the meaning:
			--   green  = line(s) added      (▎ green bar)
			--   orange = line(s) changed    (▎ orange bar)
			--   red    = line(s) deleted    (▁/▔ red underline where content was removed)
			-- The exact colours are set in lua/plugins/colors.lua so they follow the theme.
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "▁" },
				topdelete = { text = "▔" },
				changedelete = { text = "▎" },
				untracked = { text = "▏" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "▁" },
				topdelete = { text = "▔" },
				changedelete = { text = "▎" },
			},
			on_attach = function(bufnr)
				local gs = require("gitsigns")
				local function map(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
				end

				-- Navigation: jump to the next/prev change in ANY file.
				-- (gn/gt are taken by Neovim built-ins, so we use the community-standard ]h/[h.)
				-- Falls back to Vim's ]c/[c when inside a diff view.
				map("n", "]h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gs.nav_hunk("next")
					end
				end, "Next git hunk")
				map("n", "[h", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gs.nav_hunk("prev")
					end
				end, "Previous git hunk")

				-- Actions (namespaced under <leader>g, next to <leader>gg = lazygit)
				map("n", "<leader>gp", gs.preview_hunk, "Preview hunk (what changed)")
				map("n", "<leader>gs", gs.stage_hunk, "Stage/unstage hunk")
				map("n", "<leader>gr", gs.reset_hunk, "Reset hunk (discard change)")
				map("v", "<leader>gs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Stage selected lines")
				map("v", "<leader>gr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Reset selected lines")
				map("n", "<leader>gb", function()
					gs.blame_line({ full = true })
				end, "Blame line")
				map("n", "<leader>gd", gs.diffthis, "Diff this file")
			end,
		},
	},
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {
			progress = {
				suppress_on_insert = true,
				ignore_done_already = true,
				display = {
					render_limit = 1, -- max number of messages shown at once
					done_ttl = 3, -- how long a finished message lingers in seconds
				},
			},
		},
	},
	{
		"chentoast/marks.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			default_mappings = true,
			-- builtin marks shown in the gutter too (last insert, last change, etc.)
			builtin_marks = { ".", "<", ">", "^" },
			-- wrap around the buffer when jumping between marks
			cyclic = true,
			refresh_interval = 250,
			sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
		},
	},
	{
		"christoomey/vim-tmux-navigator",
		lazy = true,
		keys = {
			{ "<m-h>", ":TmuxNavigateLeft<cr>", silent = true },
			{ "<m-j>", ":TmuxNavigateDown<cr>", silent = true },
			{ "<m-k>", ":TmuxNavigateUp<cr>", silent = true },
			{ "<m-l>", ":TmuxNavigateRight<cr>", silent = true },
			{ "<m-\\>", ":TmuxNavigatePrevious<cr>", silent = true },
		},
	},
}
