return {
	"folke/snacks.nvim",
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	priority = 1000,
	lazy = false,
	keys = {
		-- Opens lazygit in a float (uses your lazygit config, incl. delta paging).
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		-- File explorer (replaces mini.files)
		{
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
	},
	opts = {
		-- explorer is a picker source; picker must be enabled.
		-- replace_netrw = false so oil.nvim owns directory/netrw opening instead.
		picker = {
			enabled = true,
			sources = {
				-- show dotfiles in the explorer by default (toggle with `H`)
				explorer = { hidden = true },
			},
		},
		explorer = { replace_netrw = false },
		indent = {
			enabled = true,
			animate = {
				style = "down",
			},
		},
		dashboard = {
			enabled = true,
			preset = {
				header = [[
                                                                     
       ████ ██████           █████      ██                     
      ███████████             █████                             
      █████████ ███████████████████ ███   ███████████   
     █████████  ███    █████████████ █████ ██████████████   
    █████████ ██████████ █████████ █████ █████ ████ █████   
  ███████████ ███    ███ █████████ █████ █████ ████ █████  
 ██████  █████████████████████ ████ █████ █████ ████ ██████ 
        ]],
				keys = {
					{ icon = "󰈞", key = "f", desc = "Find File", action = ":Telescope find_files" },
					{ icon = "󰝒", key = "n", desc = "New File", action = ":ene | startinsert" },
					{ icon = "󰊄", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
					{ icon = "󱋡", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
					{
						icon = "󰒓",
						key = "c",
						desc = "Config",
						action = function()
							require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
						end,
					},
					{ icon = "󰒲", key = "L", desc = "Lazy", action = ":Lazy" },
					{ icon = "󰅚", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
	},
}
