return {
	"j-hui/fidget.nvim",
	event = "LspAttach",
	opts = {
		suppress_on_insert = true,
		ignore_done_already = true,
	},
	display = {
		render_limit = 1,
		done_ttl = 3,
	},
}
