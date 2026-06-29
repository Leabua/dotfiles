return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		opts = { enable_check_bracket_line = false, check_ts = true },
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},
	-- {
	--   "nvim-mini/mini"
	--   --mini surround, mini ai, mini, mini_icons - kickstart
	-- },
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {
			progress = {
				suppress_on_insert = true, -- don't show messages while in insert mode
				ignore_done_already = true, -- ignore tasks that are already complete
				display = {
					render_limit = 1, -- max number of messages shown at once
					done_ttl = 3, -- how long a finished message lingers (seconds)
				},
			},
		},
	},
}
