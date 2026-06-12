return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	opts = {
		-- THIS IS THE MAGIC SWITCH
		presets = {
			lsp_doc_border = true, -- Brings back rounded borders for hover and signature docs
		},
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
			hover = { enabled = true },
			signature = { enabled = true },
		},
	},
}
