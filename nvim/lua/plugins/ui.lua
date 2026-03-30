return {
  {
    "nvim-tree/nvim-web-devicons",
    enabled = false,
  },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        always_show_bufferline = false,
        diagnostics = "nvim_lsp",
        separator_style = "slant",
      },
    },
    keys = {
      { "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", desc = "Previous buffer" },
      { "<leader>bn", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
    event = "VeryLazy",
    opts = {
      at_edge = "stop",
    },
    keys = {
      { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Focus left split" },
      { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Focus lower split" },
      { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Focus upper split" },
      { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Focus right split" },
      { "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
      { "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
      { "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
      { "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = {
      "NvimTreeFindFile",
      "NvimTreeFocus",
      "NvimTreeToggle",
    },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
      { "<leader>fe", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal file in tree" },
    },
    opts = {
      update_focused_file = {
        enable = true,
      },
      renderer = {
        group_empty = true,
        icons = {
          show = {
            file = false,
            folder = false,
            folder_arrow = true,
            git = false,
          },
          glyphs = {
            folder = {
              arrow_closed = ">",
              arrow_open = "v",
            },
          },
        },
      },
      view = {
        width = 32,
      },
    },
  },
}
