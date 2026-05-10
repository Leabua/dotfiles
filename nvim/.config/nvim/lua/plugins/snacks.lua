return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            follow_file = true,
          },
          files = {
            hidden = true,
            sort = function(a, b)
              local a_hidden = a.file:sub(1, 1) == "."
              local b_hidden = b.file:sub(1, 1) == "."
              if a_hidden ~= b_hidden then return b_hidden end
              return a.file < b.file
            end,
          },
          -- Apply the same hidden file visibility to grep
          grep = {
            hidden = true,
          },
        },
      },
    },
    keys = {
      -- 1. Grep CWD (Lower g)
      {
        "<leader>sg",
        function() Snacks.picker.grep({ cwd = vim.fn.getcwd() }) end,
        desc = "Grep (CWD)",
      },
      -- 2. Grep Root (Upper G)
      {
        "<leader>sG",
        function() Snacks.picker.grep() end,
        desc = "Grep (Root Dir)",
      },
      -- Existing <leader><space> and Explorer overrides
      {
        "<leader><space>",
        function() Snacks.picker.files({ cwd = vim.fn.getcwd() }) end,
        desc = "Find Files (CWD)",
      },
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
      -- Disable defaults to ensure your overrides take priority
      { "<leader>fe", false },
      { "<leader>fE", false },
      { "<leader>/",  false }, -- Usually Grep (Root), disable if you prefer <leader>sg
    },
  },
}
