return {
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = {
      "AerialToggle",
      "AerialOpen",
      "AerialNext",
      "AerialPrev",
    },
    keys = {
      { "<leader>o", "<cmd>AerialToggle<CR>", desc = "Toggle outline" },
    },
    opts = {
      layout = {
        default_direction = "right",
        min_width = 30,
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    keys = {
      { "<leader>m", "<cmd>RenderMarkdown toggle<CR>", desc = "Toggle markdown render" },
    },
    opts = {},
  },
}
