return {
	{
		"EdenEast/nightfox.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("nightfox").setup({
				options = {
					transparent = true,
					dim_inactive = false,
					-- bold the syntax so the colours pop on the words
					styles = {
						comments = "italic",
					},
				},
				groups = {
					all = {
						-- jagged diagnostic underlines: red errors, blue everything-else
						DiagnosticUnderlineError = { style = "undercurl", sp = "palette.red.base" },
						DiagnosticUnderlineWarn = { style = "undercurl", sp = "palette.blue.base" },
						DiagnosticUnderlineInfo = { style = "undercurl", sp = "palette.blue.base" },
						DiagnosticUnderlineHint = { style = "undercurl", sp = "palette.blue.base" },
						DiagnosticUnnecessary = { style = "undercurl", sp = "palette.blue.base" },
					},
				},
			})

			vim.cmd.colorscheme("nightfox")

			local palette = require("nightfox.palette").load("nightfox")

			-- Snacks dashboard header + directory follow the colorscheme
			vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = palette.red.base })
			vim.api.nvim_set_hl(0, "Directory", { fg = palette.blue.base, bg = "NONE" })

			local transparent_groups = {
				-- editor core
				"Normal",
				"NormalNC",
				"EndOfBuffer",
				"MsgArea",
				"MsgSeparator",
				"StatusLine",
				"StatusLineNC",
				"WinBar",
				"WinBarNC",
				"WinSeparator",
				-- floats / popups and their chrome
				"NormalFloat",
				"FloatBorder",
				"FloatTitle",
				"FloatFooter",
				"FloatShadow",
				"FloatShadowThrough",
				"Pmenu",
				"PmenuKind",
				"PmenuExtra",
				"PmenuSbar",
				-- number column / gutter (LineNrAbove/Below link to LineNr)
				"SignColumn",
				"LineNr",
				"CursorLineNr",
				"FoldColumn",

				-- diagnostic + git signs (themes often tint these even with
				-- transparent = true; this is what bled into the noice borders)
				"DiagnosticSignError",
				"DiagnosticSignWarn",
				"DiagnosticSignInfo",
				"DiagnosticSignHint",
				"DiagnosticSignOk",
				"GitSignsAdd",
				"GitSignsChange",
				"GitSignsDelete",
				"TreesitterContextLineNumber",
				"NotifyBackground",
			}

			local function strip_backgrounds()
				for _, group in ipairs(transparent_groups) do
					local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
					if next(hl) ~= nil then
						hl.bg = nil
						hl.ctermbg = nil
						vim.api.nvim_set_hl(0, group, hl)
					end
				end
			end

			strip_backgrounds()
			vim.api.nvim_create_autocmd("ColorScheme", { callback = strip_backgrounds })

			-- Gitsigns gutter colours: an unmistakable green / orange / red triad.
			-- Orange (instead of the muddy default yellow) makes "changed" read clearly
			-- distinct from "added". fg-only so the sign column stays transparent.
			local function set_git_signs()
				local p = require("nightfox.palette").load("nightfox")
				vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = p.green.bright, bg = "NONE" })
				vim.api.nvim_set_hl(0, "GitSignsChange", { fg = p.orange.base, bg = "NONE" })
				vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = p.orange.base, bg = "NONE" })
				vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = p.red.bright, bg = "NONE" })
				vim.api.nvim_set_hl(0, "GitSignsTopdelete", { fg = p.red.bright, bg = "NONE" })
				vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = p.green.dim, bg = "NONE" })
			end

			set_git_signs()
			-- run after strip_backgrounds on re-theme so our explicit fg wins
			vim.api.nvim_create_autocmd("ColorScheme", { callback = set_git_signs })
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		opts = {},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = function()
			local theme = require("lualine.themes.seoul256")
			-- local theme = require("lualine.themes.palenight")
			for _, mode in pairs(theme) do
				if mode.b then
					mode.b.bg = "NONE"
				end
				if mode.c then
					mode.c.bg = "NONE"
				end
			end

			-- show macro recording status in the statusline (cmdheight=0 hides neovim's default "recording @q" message).
			local function macro_recording()
				local reg = vim.fn.reg_recording()
				if reg == "" then
					return ""
				end
				return "recording @" .. reg
			end

			local macro_group = vim.api.nvim_create_augroup("LualineMacroRecording", { clear = true })
			vim.api.nvim_create_autocmd("RecordingEnter", {
				group = macro_group,
				callback = function()
					require("lualine").refresh()
				end,
			})
			vim.api.nvim_create_autocmd("RecordingLeave", {
				group = macro_group,
				callback = function()
					-- reg_recording() is still set during RecordingLeave, so repaint next tick
					vim.defer_fn(function()
						require("lualine").refresh()
					end, 50)
				end,
			})

			return {
				options = {
					theme = theme,
					section_separators = { left = "\u{e0b1}", right = "\u{e0b3}" },
				},
				sections = {
					-- keep the filled triangle caps on the coloured end sections
					lualine_a = { { "mode", separator = { right = "\u{e0b0}" } } },
					lualine_c = {
						"filename",
						{ macro_recording, color = { fg = "#ff5555", gui = "bold" } },
					},
					lualine_z = { { "location", separator = { left = "\u{e0b2}" } } },
				},
			}
		end,
	},
}
