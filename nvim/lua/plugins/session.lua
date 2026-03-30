return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  keys = {
    { "<leader>sr", function() require("persistence").load() end, desc = "Restore session (cwd)" },
    { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    { "<leader>sd", function() require("persistence").stop() end, desc = "Stop auto-save session" },
  },
}
