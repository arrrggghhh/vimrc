local map = vim.keymap.set
local lsp_navigation = require("config.lsp_navigation")

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer", silent = true })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window", silent = true })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer", silent = true })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })
map("n", "gd", lsp_navigation.goto_definition_in_other_window, { desc = "Go to definition in split", silent = true })
map("n", "<leader>h", "<C-w>h", { desc = "Focus left window" })
map("n", "<leader>j", "<C-w>j", { desc = "Focus lower window" })
map("n", "<leader>k", "<C-w>k", { desc = "Focus upper window" })
map("n", "<leader>l", "<C-w>l", { desc = "Focus right window" })
map("n", "<A-z>", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.wo.linebreak = vim.wo.wrap
end, { desc = "Toggle word wrap", silent = true })

local function copy_path_location(modifier, mode)
  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), modifier)
  local result
  if mode == "v" then
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    result = path .. ":" .. (start_line == end_line and start_line or start_line .. "-" .. end_line)
  else
    result = path .. ":" .. vim.fn.line(".")
  end
  vim.fn.setreg("+", result)
  vim.notify(result, vim.log.levels.INFO)
end

map("n", "<leader>yp", function() copy_path_location(":~:.", "n") end, { desc = "Copy relative path:line", silent = true })
map("v", "<leader>yp", function() copy_path_location(":~:.", "v") end, { desc = "Copy relative path:range", silent = true })
map("n", "<leader>yP", function() copy_path_location(":p", "n") end, { desc = "Copy absolute path:line", silent = true })
map("v", "<leader>yP", function() copy_path_location(":p", "v") end, { desc = "Copy absolute path:range", silent = true })
