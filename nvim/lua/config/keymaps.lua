local map = vim.keymap.set
local lsp_navigation = require("config.lsp_navigation")

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Write buffer", silent = true })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window", silent = true })

local function close_buffer_keep_window()
  local current = vim.api.nvim_get_current_buf()
  local alternate = vim.fn.bufnr("#")

  if alternate > 0 and vim.api.nvim_buf_is_valid(alternate) and vim.bo[alternate].buflisted then
    vim.cmd.buffer(alternate)
  else
    local replacement
    for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
      if buf.bufnr ~= current then
        replacement = buf.bufnr
        break
      end
    end

    if replacement then
      vim.cmd.buffer(replacement)
    else
      vim.cmd.enew()
    end
  end

  if vim.api.nvim_buf_is_valid(current) then
    vim.cmd.bdelete(current)
  end
end

local function delete_other_buffers_keep_visible(args)
  local keep = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_is_valid(buf) then
        keep[buf] = true
      end
    end
  end

  local deleted = 0
  local failed = 0

  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if not keep[buf.bufnr] then
      local cmd = (args.bang and "bdelete! " or "bdelete ") .. buf.bufnr
      local ok = pcall(vim.cmd, cmd)
      if ok then
        deleted = deleted + 1
      else
        failed = failed + 1
      end
    end
  end

  if failed > 0 then
    vim.notify(
      string.format("Deleted %d buffers, %d could not be deleted", deleted, failed),
      vim.log.levels.WARN
    )
    return
  end

  vim.notify(
    deleted == 0 and "No hidden buffers to delete" or string.format("Deleted %d hidden buffers", deleted),
    vim.log.levels.INFO
  )
end

map("n", "<leader>bd", close_buffer_keep_window, { desc = "Delete buffer", silent = true })
vim.api.nvim_create_user_command("BufOnlyVisible", delete_other_buffers_keep_visible, {
  bang = true,
  desc = "Delete all listed buffers except those visible in windows",
})
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer", silent = true })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer", silent = true })
map("n", "gd", lsp_navigation.goto_definition_in_other_window, { desc = "Go to definition in split", silent = true })
map("n", "gzd", lsp_navigation.goto_definition_in_new_tab, { desc = "Go to definition in new tab", silent = true })
map("n", "<leader>h", "<C-w>h", { desc = "Focus left window" })
map("n", "<leader>j", "<C-w>j", { desc = "Focus lower window" })
map("n", "<leader>k", "<C-w>k", { desc = "Focus upper window" })
map("n", "<leader>l", "<C-w>l", { desc = "Focus right window" })
local function toggle_maximize()
  if vim.fn.winnr("$") == 1 then
    return
  end
  if vim.t.maximized_sizes then
    vim.cmd("silent! " .. vim.t.maximized_sizes.before)
    if vim.fn.winrestcmd() ~= vim.t.maximized_sizes.before then
      vim.cmd("wincmd =")
    end
    vim.t.maximized_sizes = nil
  else
    local before = vim.fn.winrestcmd()
    vim.cmd("vert resize | resize")
    vim.t.maximized_sizes = { before = before, after = vim.fn.winrestcmd() }
  end
end

map("n", "<C-w>m", toggle_maximize, { desc = "Toggle maximize window", silent = true })

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
