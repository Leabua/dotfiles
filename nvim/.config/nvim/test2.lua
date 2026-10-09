require("lazy").setup({
  { "folke/tokyonight.nvim", lazy = true },
})
print("Before:", vim.g.colors_name)
pcall(vim.cmd.colorscheme, "tokyonight")
print("After:", vim.g.colors_name)
