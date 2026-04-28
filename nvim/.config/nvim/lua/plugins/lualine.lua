return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.globalstatus = true
      opts.options.theme = {
        normal = { a = { bg = "none" }, b = { bg = "none" }, c = { bg = "none" } },
        insert = { a = { bg = "none" }, b = { bg = "none" } },
        visual = { a = { bg = "none" }, b = { bg = "none" } },
        command = { a = { bg = "none" }, b = { bg = "none" } },
        inactive = { a = { bg = "none" }, b = { bg = "none" }, c = { bg = "none" } },
      }
      return opts
    end,
    config = function(_, opts)
      require("lualine").setup(opts)
      vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "lualine_transparent", { bg = "none" })
    end,
  },
}
