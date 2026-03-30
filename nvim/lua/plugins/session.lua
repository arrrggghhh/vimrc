return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  keys = {
    { "<leader>sr", function() require("persistence").load() end, desc = "Restore session (cwd)" },
    { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    { "<leader>ss", function() require("persistence").save() end, desc = "Save session" },
  },
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)
    persistence.stop()

    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        local bufs = vim.tbl_filter(function(b)
          if vim.bo[b].buftype ~= "" then return false end
          if vim.bo[b].filetype == "gitcommit" or vim.bo[b].filetype == "gitrebase" then return false end
          return vim.api.nvim_buf_get_name(b) ~= ""
        end, vim.api.nvim_list_bufs())

        if #bufs < 2 then return end

        local choice = vim.fn.confirm("Save session?", "&Yes\n&No", 2)
        if choice == 1 then
          persistence.save()
        end
      end,
    })
  end,
}
