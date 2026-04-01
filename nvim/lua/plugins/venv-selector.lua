return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
  },
  branch = "regexp",
  ft = "python",
  keys = {
    { "<leader>vs", "<cmd>VenvSelect<CR>", desc = "Select virtualenv" },
  },
  opts = {},
}
