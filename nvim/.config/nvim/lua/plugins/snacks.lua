return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            -- Shows hidden files (dotfiles) and git-ignored files by default
            hidden = true,
            ignored = true,
            -- This ensures the explorer follows your logic even when called simply
            follow_file = true,
          },
        },
      },
    },
    keys = {
      -- 1. Swap the keys: lower 'e' for CWD, upper 'E' for Root
      {
        "<leader>e",
        function() Snacks.explorer({ cwd = vim.fn.getcwd() }) end,
        desc = "Explorer (CWD)"
      },
      {
        "<leader>E",
        function() Snacks.explorer() end,
        desc = "Explorer (Root Dir)"
      },
      -- 2. Unbind the default LazyVim mappings to prevent conflicts
      { "<leader>fe", false },
      { "<leader>fE", false },
    },
  },
}
