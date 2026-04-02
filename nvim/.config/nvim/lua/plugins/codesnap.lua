return {
  "mistricky/codesnap.nvim",
  build = "make",
  keys = {
    { "<leader>cc", "<cmd>CodeSnap<cr>",     mode = "x", desc = "Save selected code snapshot to clipboard" },
    { "<leader>cs", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
  },
  opts = {
    -- Use the full absolute path to your Pictures folder
    save_path = "/home/leabua/Pictures",
    has_line_number = true,
    bg_theme = "summer",
    watermark = "",
    has_border = true,
    column_id = "codesnap",
  },
}
