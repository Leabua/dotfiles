-- colors/zednight.lua
vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.g.colors_name = "zednight"

-- ==========================================
-- 1. THE STRICT CUSTOM PALETTE (Zero Orange)
-- ==========================================
local c = {
	bg = "NONE", -- Transparent editor
	panel_bg = "#161616", -- Solid popups/panels

	white = "#c0caf5", -- Plain text, standard variables
	emerald = "#08bdba", -- Strings
	teal = "#4fd6be", -- Built-in Types (string, number)

	red40 = "#f7768e", -- Snacks header, numbers, booleans, regex
	purple = "#bb9af7", -- Keywords (const, return, async)

	blue_dark = "#78a9ff", -- Functions & Methods (.replace, map)
	blue_light = "#7dcfff", -- Parameters, Properties, Operators

	comment = "#565f89", -- Comments

	-- UI & Diagnostics
	error = "#f7768e", -- Magenta/Red
	warning = "#e0af68", -- Soft Yellow (only for warning underlines)
	info = "#7dcfff", -- Light Blue
	hint = "#4fd6be", -- Teal
	selection = "#283457",
}

local groups = {
	-- Base Editor
	Normal = { fg = c.white, bg = c.bg },
	NormalFloat = { fg = c.white, bg = c.panel_bg },
	FloatBorder = { fg = c.blue_light, bg = c.panel_bg },
	Comment = { fg = c.comment, italic = true }, -- ONLY italicized item
	String = { fg = c.emerald },
	Number = { fg = c.red40 },
	Boolean = { fg = c.red40 },
	Visual = { bg = c.selection },
	MatchParen = { fg = c.red40, bg = "NONE", bold = true, underline = true },
	CursorLine = { bg = "#1e202e" },

	-- UI Popups & Snacks
	Pmenu = { bg = c.panel_bg, fg = c.white },
	PmenuSel = { bg = c.selection, fg = "NONE" },
	PmenuSbar = { bg = c.panel_bg },
	PmenuThumb = { bg = c.comment },

	SnacksNormal = { bg = c.panel_bg, fg = c.white },
	SnacksNormalFloat = { bg = c.panel_bg, fg = c.white },
	SnacksBorder = { bg = c.panel_bg, fg = c.blue_light },
	SnacksBorderFloat = { bg = c.panel_bg, fg = c.blue_light },
	SnacksPickerMatch = { fg = c.blue_dark, bold = true },
	SnacksDashboardHeader = { fg = c.emerald }, -- Hardcoded tokyo night Blue Header
	-- SnacksDashboardHeader = { fg = c.red40 }, -- Hardcoded Magenta Header

	OilBackground = { bg = c.panel_bg },
	OilFloatBorder = { bg = c.panel_bg, fg = c.blue_light },

	-- ==========================================
	-- Hover Popups & Markdown Backgrounds
	-- ==========================================
	-- FloatTitle = { bg = c.panel_bg, fg = c.red40, bold = true },
	FloatTitle = { bg = c.panel_bg, fg = c.emerald, bold = true },
	LspInfoNormal = { bg = c.panel_bg, fg = c.white },
	LspInfoBorder = { bg = c.panel_bg, fg = c.blue_light },

	-- Strip Treesitter from painting a highlight block over your #1e1e1e window
	["@markup"] = { bg = "NONE", fg = c.white },
	["@markup.raw"] = { bg = "NONE", fg = c.white },
	["@markup.raw.block"] = { bg = "NONE", fg = c.white },
	["@markup.raw.inline"] = { bg = "NONE", fg = c.blue_light },
	["@markup.raw.block.markdown"] = { bg = "NONE", fg = c.white },
	markdownCode = { bg = "NONE", fg = c.white },
	markdownCodeBlock = { bg = "NONE", fg = c.white },

	-- Strip render-markdown.nvim backgrounds
	RenderMarkdownCode = { bg = "NONE" },
	RenderMarkdownCodeInline = { bg = "NONE" },

	-- Keywords (Purple, NO Italics)
	Keyword = { fg = c.purple },
	Statement = { fg = c.purple },
	Conditional = { fg = c.purple },
	Repeat = { fg = c.purple },
	Exception = { fg = c.purple },
	["@keyword"] = { fg = c.purple },
	["@keyword.function"] = { fg = c.purple },
	["@keyword.coroutine"] = { fg = c.purple },
	["@keyword.return"] = { fg = c.purple },

	-- Operators & Punctuation (Light Blue)
	Operator = { fg = c.blue_light },
	Delimiter = { fg = c.blue_light },
	["@operator"] = { fg = c.blue_light },
	["@punctuation.delim"] = { fg = c.blue_light },
	["@punctuation.bracket"] = { fg = c.white },

	-- Functions & Methods (Dark Blue)
	Function = { fg = c.blue_dark },
	["@function"] = { fg = c.blue_dark },
	["@function.call"] = { fg = c.blue_dark },
	["@function.method"] = { fg = c.blue_dark },
	["@function.method.call"] = { fg = c.blue_dark },

	-- Parameters & Properties (Light Blue)
	["@variable.parameter"] = { fg = c.blue_light },
	["@parameter"] = { fg = c.blue_light },
	["@property"] = { fg = c.blue_light },
	["@variable.member"] = { fg = c.blue_light },

	-- Variables (White)
	Identifier = { fg = c.white },
	["@variable"] = { fg = c.white },
	["@variable.builtin"] = { fg = c.red40 },

	-- Types & Classes (Teal)
	Type = { fg = c.teal },
	["@type"] = { fg = c.teal },
	["@class"] = { fg = c.teal },
	["@constructor"] = { fg = c.red40 },
	["@type.builtin"] = { fg = c.teal },

	-- Regex (Magenta)
	["@string.regexp"] = { fg = c.red40 },

	-- Diagnostics
	DiagnosticError = { fg = c.error },
	DiagnosticWarn = { fg = c.warning },
	DiagnosticInfo = { fg = c.info },
	DiagnosticHint = { fg = c.hint },
	DiagnosticUnnecessary = { fg = "NONE" },
	DiagnosticUnderlineError = { sp = c.error, undercurl = true },
	DiagnosticUnderlineWarn = { sp = c.warning, undercurl = true },
	DiagnosticUnderlineInfo = { sp = c.info, undercurl = true },
	DiagnosticUnderlineHint = { sp = c.hint, undercurl = true },

	-- 3. LSP SEMANTIC LOCK (Prevents TS overrides)
	-- ==========================================
	["@lsp.type.variable"] = { fg = c.white },
	["@lsp.type.parameter"] = { fg = c.blue_light },
	["@lsp.type.property"] = { fg = c.blue_light },
	["@lsp.type.function"] = { fg = c.blue_dark },
	["@lsp.type.method"] = { fg = c.blue_dark },
	["@lsp.type.class"] = { fg = c.teal },
	["@lsp.type.type"] = { fg = c.teal },

	["@lsp.typemod.function.defaultLibrary"] = { fg = c.blue_dark },
	["@lsp.typemod.method.defaultLibrary"] = { fg = c.blue_dark },
	["@lsp.typemod.property.defaultLibrary"] = { fg = c.blue_dark },
	["@lsp.typemod.variable.defaultLibrary"] = { fg = c.white },
	["@lsp.typemod.type.defaultLibrary"] = { fg = c.teal },
	["@lsp.typemod.member.defaultLibrary"] = { fg = c.blue_dark },
}

-- Execute layout definitions
for group, settings in pairs(groups) do
	vim.api.nvim_set_hl(0, group, settings)
end
