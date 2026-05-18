return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		cmdline = {
			enabled = true,
			view = "cmdline_popup",
			opts = {
				position = {
					row = 3,
					col = "50%",
				},
			},
		},
		messages = {
			enabled = true,
		},
		popupmenu = {
			enabled = true,
		},
		notify = {
			enabled = false,
		},
		lsp = {
			progress = { enabled = false },
			hover = { enabled = false },
			signature = { enabled = false },
		},
	},
}
