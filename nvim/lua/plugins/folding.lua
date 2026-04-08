return {
  "kevinhwang91/nvim-ufo",
  dependencies = { "kevinhwang91/promise-async" },
  event = "BufReadPost",
  init = function()
    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,
  keys = {
    { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
    { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
    { "zK", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek folded lines" },
  },
  opts = {
    open_fold_hl_timeout = 150,
    close_fold_kinds_for_ft = {
      default = { "imports", "comment" },
      json = { "array" },
    },
    preview = {
      win_config = {
        border = { "", "─", "", "", "", "─", "", "" },
        winhighlight = "Normal:Folded",
        winblend = 0,
      },
      mappings = {
        scrollU = "<C-u>",
        scrollD = "<C-d>",
        jumpTop = "[",
        jumpBot = "]",
      },
    },
    provider_selector = function(_, _, _)
      return { "treesitter", "indent" }
    end,
  },
  config = function(_, opts)
    require("ufo").setup(opts)
  end,
}
