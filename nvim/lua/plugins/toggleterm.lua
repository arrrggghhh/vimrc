return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<C-\\>", desc = "Toggle terminal" },
    { "<leader>tf", desc = "Float terminal" },
    { "<leader>th", desc = "Horizontal terminal" },
    { "<leader>tv", desc = "Vertical terminal" },
    { "<leader>tg", desc = "Lazygit" },
  },
  opts = {
    open_mapping = [[<C-\>]],
    direction = "float",
    float_opts = {
      border = "curved",
    },
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      direction = "float",
      hidden = true,
      float_opts = { border = "curved" },
    })

    local map = vim.keymap.set
    map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Float terminal" })
    map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "Horizontal terminal" })
    map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", { desc = "Vertical terminal" })
    map("n", "<leader>tg", function() lazygit:toggle() end, { desc = "Lazygit" })

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm#*",
      callback = function()
        local topts = { buffer = 0 }
        map("t", "<Esc>", [[<C-\><C-n>]], topts)
        map("t", "<C-h>", [[<C-\><C-n><C-w>h]], topts)
        map("t", "<C-j>", [[<C-\><C-n><C-w>j]], topts)
        map("t", "<C-k>", [[<C-\><C-n><C-w>k]], topts)
        map("t", "<C-l>", [[<C-\><C-n><C-w>l]], topts)
      end,
    })
  end,
}
