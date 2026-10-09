local lazy_ok = pcall(function() require("lazy").load({ plugins = { "tokyonight.nvim" } }) end)
local cs_ok = pcall(vim.cmd.colorscheme, "tokyonight-moon")
print("lazy ok:", lazy_ok, "cs ok:", cs_ok)
