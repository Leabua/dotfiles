return {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter", -- Keep it fast, only load when you start typing
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		-- The Snippet Ecosystem
		"L3MON4D3/LuaSnip", -- The engine
		"saadparwaiz1/cmp_luasnip", -- The bridge to cmp
		"rafamadriz/friendly-snippets", -- The pre-made snippets
	},
	config = function()
		local cmp = require("cmp")
		local luasnip = require("luasnip")

		-- This line tells LuaSnip to load the friendly-snippets library
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			-- Tell cmp that LuaSnip is the engine handling the expansions
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),

				-- Super-Tab behavior:
				-- 1. Move down the menu if visible.
				-- 2. Expand a snippet if typed.
				-- 3. Jump to the next variable inside an active snippet.
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s" }),

				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
			-- The order here determines priority in the popup menu
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- Activate snippets in the menu
				{ name = "buffer" },
				{ name = "path" },
			}),
			window = {
				completion = cmp.config.window.bordered({
					border = "rounded",
					winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
				}),
				documentation = cmp.config.window.bordered({
					border = "rounded",
					winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
				}),
			},
		})
	end,
}
