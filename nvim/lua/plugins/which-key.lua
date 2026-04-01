return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.which_key_disabled = true
  end,
  opts = {
    delay = function(ctx)
      if vim.g.which_key_disabled then
        return math.huge
      end
      return ctx.plugin and 0 or 200
    end,
    spec = {
      { "<leader>c", group = "code" },
      { "<leader>d", group = "debug" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>s", group = "session" },
      { "<leader>t", group = "terminal" },
      { "<leader>v", group = "venv" },
    },
  },
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "Buffer keymaps",
    },
    {
      "<leader>k",
      function()
        vim.g.which_key_disabled = not vim.g.which_key_disabled
        vim.notify(
          "Which-Key " .. (vim.g.which_key_disabled and "OFF" or "ON"),
          vim.log.levels.INFO
        )
      end,
      desc = "Toggle which-key",
    },
  },
}
