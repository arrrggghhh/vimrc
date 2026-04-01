return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = "ConformInfo",
  opts = {
    formatters_by_ft = {
      python = { "ruff_fix", "ruff_format" },
    },
    format_on_save = {
      timeout_ms = 3000,
      lsp_format = "never",
    },
  },
}
