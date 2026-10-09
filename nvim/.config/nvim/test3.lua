print("START")
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local ok = pcall(vim.cmd.colorscheme, "tokyonight-moon")
    print("VimEnter ok:", ok)
    print("Colors:", vim.g.colors_name)
  end
})
