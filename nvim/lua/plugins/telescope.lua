return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<leader>fr", "<cmd>Telescope resume<CR>", desc = "Resume last search" },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
          file_ignore_patterns = { "%.git/", "node_modules/", "vendor/" },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      })

      telescope.load_extension("fzf")
    end,
  },
}
