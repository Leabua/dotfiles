return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.globalstatus = true
      local theme = require("lualine.themes.auto")
      theme.normal.c.bg = "none"
      if theme.insert and theme.insert.c then
        theme.insert.c.bg = "none"
      end
      if theme.visual and theme.visual.c then
        theme.visual.c.bg = "none"
      end
      if theme.command and theme.command.c then
        theme.command.c.bg = "none"
      end
      if theme.inactive and theme.inactive.c then
        theme.inactive.c.bg = "none"
      end
      opts.options.theme = theme
      return opts
    end,
    config = function(_, opts)
      require("lualine").setup(opts)
      vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
      vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
      vim.api.nvim_set_hl(0, "lualine_transparent", { bg = "none" })
      vim.api.nvim_set_hl(0, "lualine_c_normal", { bg = "none" })
    end,
  },
}
