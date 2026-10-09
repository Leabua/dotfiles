print("Before VimEnter")
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local ok, err = pcall(vim.cmd.colorscheme, "tokyonight")
    print("VimEnter pcall result:", ok, err)
  end
})
