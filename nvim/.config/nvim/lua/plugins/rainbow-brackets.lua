return {
  "HiPhish/rainbow-delimiters.nvim",
  config = function()
    vim.g.rainbow_delimiters = {
      highlight = {
        "RainbowDelimiterViolet",
        "RainbowDelimiterBlue",
        "RainbowDelimiterGreen",
        "RainbowDelimiterOrange",
        "RainbowDelimiterYellow",
        "RainbowDelimiterCyan",
      },
    }
  end,
}
