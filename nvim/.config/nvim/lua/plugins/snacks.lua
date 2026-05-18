return {
	"folke/snacks.nvim",
	dependencies = {
		"echasnovski/mini.icons",
	},
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true },
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
					{
						icon = "󰈞",
						key = "f",
						desc = "Find File",
						action = ":lua Snacks.picker.files({ cwd = vim.fn.getcwd() })",
					},
					{ icon = "󰝒", key = "n", desc = "New File", action = ":ene | startinsert" },
					{
						icon = "󰊄",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.picker.grep({ cwd = vim.fn.getcwd() })",
					},
					{ icon = "󱋡", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
					{
						icon = "󰒓",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })",
					},
					{ icon = "󰒲", key = "L", desc = "Lazy", action = ":Lazy" },
					{ icon = "󰅚", key = "q", desc = "Quit", action = ":qa" },
				},
			},
		},
		indent = { enabled = true },
		input = { enabled = true },
		git = { enabled = true },
		-- always scope files and grep to cwd, hidden files excluded by default
		picker = {
			enabled = true,
			sources = {
				files = {
					cwd = vim.fn.getcwd(),
					hidden = false,
				},
				grep = {
					cwd = vim.fn.getcwd(),
				},
			},
		},
		notifier = { enabled = true },
		quickfile = { enabled = true },
		scroll = { enabled = false },
		statuscolumn = { enabled = true },
		words = { enabled = true },
	},
	keys = {
		{
			"<C-p>",
			-- explicitly pass cwd so it always opens in the current working directory
			function()
				Snacks.picker.files({ cwd = vim.fn.getcwd() })
			end,
			desc = "Find Files",
		},
		{
			"<leader><leader>",
			-- scoped to cwd instead of recent
			function()
				Snacks.picker.files({ cwd = vim.fn.getcwd() })
			end,
			desc = "Find Files (cwd)",
		},
		{
			"<leader>fg",
			-- explicitly pass cwd so grep always searches from current working directory
			function()
				Snacks.picker.grep({ cwd = vim.fn.getcwd() })
			end,
			desc = "Grep Files",
		},
		{
			"<leader>e",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
	},
}
