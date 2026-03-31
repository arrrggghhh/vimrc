local M = {}

local sidebar_filetypes = {
  NvimTree = true,
  aerial = true,
  qf = true,
  help = true,
  toggleterm = true,
}

local function is_sidebar(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype
  return sidebar_filetypes[ft] or false
end

local function next_window(source_win)
  local total = vim.fn.winnr("$")
  if total <= 1 then
    return nil
  end

  local current = vim.fn.win_id2win(source_win)
  if current == 0 then
    return nil
  end

  for i = 1, total - 1 do
    local nr = (current - 1 + i) % total + 1
    local win = vim.fn.win_getid(nr)
    if win ~= source_win and not is_sidebar(win) then
      return win
    end
  end

  return nil
end

local function prepare_other_window(source_buf, source_win, source_cursor)
  if not vim.api.nvim_buf_is_valid(source_buf) then
    return nil
  end

  local target_win = next_window(source_win)
  if not target_win or not vim.api.nvim_win_is_valid(target_win) then
    if vim.api.nvim_win_is_valid(source_win) then
      vim.api.nvim_set_current_win(source_win)
    end
    vim.cmd("vsplit")
    target_win = vim.api.nvim_get_current_win()
  end

  vim.api.nvim_win_set_buf(target_win, source_buf)
  vim.api.nvim_win_set_cursor(target_win, source_cursor)
  return target_win
end

local function open_lsp_item_in_other_window(item, source_buf, source_win, from, tagname)
  local source_cursor = { from[2], math.max(from[3] - 1, 0) }
  local target_win = prepare_other_window(source_buf, source_win, source_cursor)
  if not target_win then
    return
  end

  local target_buf = item.bufnr or vim.fn.bufadd(item.filename)
  vim.bo[target_buf].buflisted = true

  vim.api.nvim_win_call(target_win, function()
    vim.cmd("normal! m'")
    vim.fn.settagstack(target_win, { items = { { tagname = tagname, from = from } } }, "t")
    vim.api.nvim_win_set_buf(target_win, target_buf)
    vim.api.nvim_win_set_cursor(target_win, { item.lnum, math.max(item.col - 1, 0) })
    vim.cmd("normal! zv")
  end)

  vim.api.nvim_set_current_win(target_win)
end

function M.jump_in_current_window(jump)
  return function()
    jump()
  end
end

function M.jump_in_other_window(jump)
  return function()
    local source_buf = vim.api.nvim_get_current_buf()
    local source_win = vim.api.nvim_get_current_win()
    local from = vim.fn.getpos(".")
    local tagname = vim.fn.expand("<cword>")

    from[1] = source_buf

    jump({
      on_list = function(options)
        if #options.items == 1 then
          open_lsp_item_in_other_window(options.items[1], source_buf, source_win, from, tagname)
          return
        end

        vim.fn.setqflist({}, " ", options)
        vim.cmd("botright copen")
      end,
    })
  end
end

function M.goto_definition_in_other_window()
  if next(vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" })) ~= nil then
    M.jump_in_other_window(vim.lsp.buf.definition)()
    return
  end

  local source_buf = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()
  local source_cursor = vim.api.nvim_win_get_cursor(source_win)
  local target_win = prepare_other_window(source_buf, source_win, source_cursor)
  if not target_win then
    return
  end

  vim.api.nvim_set_current_win(target_win)
  vim.cmd("normal! gd")
end

return M
