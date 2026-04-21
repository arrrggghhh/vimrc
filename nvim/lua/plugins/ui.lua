return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        theme = "dragon",
      })
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
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
      { "<leader>e", "<cmd>NvimTreeFocus<CR>", desc = "Focus file tree" },
      { "<leader>fe", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal file in tree" },
    },
    opts = {
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")

        local function map_opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.del("n", "<CR>", { buffer = bufnr })
        vim.keymap.del("n", "o", { buffer = bufnr })
        vim.keymap.set("n", "<CR>", api.node.open.no_window_picker, map_opts("Open: No Window Picker"))
        vim.keymap.set("n", "o", api.node.open.edit, map_opts("Open"))

        vim.keymap.set("n", "E", function()
          local node = api.tree.get_node_under_cursor()
          if not node then return end
          local start_path = node.absolute_path
          api.tree.expand_all(nil, {
            expand_until = function(_, n)
              return n.parent ~= nil and n.parent.absolute_path == start_path
            end,
          })
        end, map_opts("Expand Two Levels"))
      end,
      actions = {
        open_file = {
          resize_window = false,
          window_picker = {
            enable = true,
          },
        },
      },
      filters = {
        custom = { "^\\.git$" },
      },
      update_focused_file = {
        enable = true,
      },
      renderer = {
        group_empty = true,
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
      },
      view = {
        width = 32,
      },
    },
  },
}
