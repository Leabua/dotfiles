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
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next todo comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous todo comment",
			},
			{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Search todos" },
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = function()
			local theme = require("lualine.themes.seoul256")
			-- local theme = require("lualine.themes.palenight")
			for _, mode in pairs(theme) do
				-- lualine_a's fg is near-black, meant to sit on its own bright
				-- mode-colored pill (that bg is the only per-mode color cue).
				-- Stripping every bg below would leave dark text on nothing, so
				-- promote that accent color to fg first: readable, still
				-- color-coded per mode, no filled pill.
				if mode.a and mode.a.bg then
					mode.a.fg = mode.a.bg
				end
				for _, section in pairs(mode) do
					section.bg = "NONE"
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
					-- powerline arrow glyphs (e0b0-e0b3) are solid-filled characters —
					-- they render as solid shapes from their own foreground ink, with
					-- no bg involved, so they show up as dividers even on a fully
					-- transparent statusline. Drop them entirely: flat text, no dividers.
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_c = {
						"filename",
						{ macro_recording, color = { fg = "#ff5555", gui = "bold" } },
					},
					lualine_z = { "location" },
				},
			}
		end,
	},
}
