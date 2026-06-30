return {
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("kanagawa").setup({
				theme = "wave",
				transparent = true,
				dimInactive = false,
				undercurl = true,
				-- bold the syntax so the colours pop on the words
				commentStyle = { italic = true },
				keywordStyle = { italic = false, bold = true },
				functionStyle = { bold = true },
				statementStyle = { bold = true },
				typeStyle = { bold = true },
				overrides = function(colors)
					local p = colors.palette
					return {
						["@function"] = { fg = p.crystalBlue, bold = true },
						["@function.call"] = { fg = p.crystalBlue, bold = true },
						["@function.builtin"] = { fg = p.springBlue, bold = true },
						["@keyword"] = { fg = p.oniViolet, bold = true },
						["@keyword.function"] = { fg = p.oniViolet, bold = true },
						["@type"] = { fg = p.waveAqua2, bold = true },
						["@constant"] = { fg = p.surimiOrange },
						["@constant.builtin"] = { fg = p.surimiOrange },
						["@string"] = { fg = p.springGreen },
						["@number"] = { fg = p.sakuraPink },
						["@variable.builtin"] = { fg = p.waveRed },
						["@property"] = { fg = p.carpYellow },
					}
				end,
			})

			vim.cmd.colorscheme("kanagawa-wave")

			local palette = require("kanagawa.colors").setup({ theme = "wave" }).palette

			-- Snacks dashboard header + directory follow the colorscheme
			vim.api.nvim_set_hl(0, "SnacksDashboardHeader", { fg = palette.peachRed })
			vim.api.nvim_set_hl(0, "Directory", { fg = palette.crystalBlue, bg = "NONE" })

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

				-- diagnostic + git signs (kanagawa tints these #2a2a37 even with
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
