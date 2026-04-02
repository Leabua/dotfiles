return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      -- This disables the automatic floating window
      setup = {
        setup_handlers = function()
          vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
            vim.lsp.handlers.signature_help, {
              focusable = false,
              silent = true,
            }
          )
        end,
      },
    },
  },
}
