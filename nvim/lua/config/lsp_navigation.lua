local util = require("vim.lsp.util")

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

local function prepare_new_tab(source_buf, source_win, source_cursor)
  if not vim.api.nvim_buf_is_valid(source_buf) then
    return nil
  end

  if vim.api.nvim_win_is_valid(source_win) then
    vim.api.nvim_set_current_win(source_win)
    vim.api.nvim_win_set_cursor(source_win, source_cursor)
  end

  vim.cmd("tab split")
  return vim.api.nvim_get_current_win()
end

local function open_lsp_item(item, source_buf, source_win, from, tagname, prepare_target)
  local source_cursor = { from[2], math.max(from[3] - 1, 0) }
  local target_win = prepare_target(source_buf, source_win, source_cursor)
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

local function open_lsp_item_in_other_window(item, source_buf, source_win, from, tagname)
  open_lsp_item(item, source_buf, source_win, from, tagname, prepare_other_window)
end

local function open_lsp_item_in_new_tab(item, source_buf, source_win, from, tagname)
  open_lsp_item(item, source_buf, source_win, from, tagname, prepare_new_tab)
end

local function normalize_inline_whitespace(text)
  return vim.trim((text or ""):gsub("%s+", " "))
end

local function hover_markdown_lines(contents)
  if type(contents) == "table" and contents.kind == "plaintext" then
    return vim.split(contents.value or "", "\n", { trimempty = true })
  end

  return util.convert_input_to_markdown_lines(contents)
end

local function first_nonempty_line(lines)
  for _, line in ipairs(lines) do
    local trimmed = vim.trim(line)
    if trimmed ~= "" and trimmed ~= "---" then
      return trimmed
    end
  end
end

local function first_code_block(lines)
  local inside = false
  local block = {}

  for _, line in ipairs(lines) do
    if line:match("^```") then
      if inside and #block > 0 then
        return block
      end
      inside = not inside
    elseif inside then
      local trimmed = vim.trim(line)
      if trimmed ~= "" then
        table.insert(block, trimmed)
      end
    end
  end

  if #block > 0 then
    return block
  end
end

local function looks_like_type(text)
  return text:match("^%*")
    or text:match("^%[%]")
    or text:match("^map%[")
    or text:match("^chan[%s<]")
    or text:match("^<-chan%s")
    or text:match("^func%s*%(")
    or text:match("^struct%s*{")
    or text:match("^interface%s*{")
    or text:match("^[%w_%.]+$")
    or text:match("^[%w_%.]+%b[]")
end

local function extract_type_from_line(line)
  line = normalize_inline_whitespace(line)
  if line == "" then
    return nil
  end

  local declared_type = line:match("^var%s+[%w_,%s]+%s+(.+)$")
    or line:match("^const%s+[%w_,%s]+%s+(.+)$")
    or line:match("^field%s+[%w_,%s]+%s+(.+)$")
    or line:match("^parameter%s+[%w_,%s]+%s+(.+)$")
  if declared_type then
    return normalize_inline_whitespace(declared_type)
  end

  local colon_type = line:match("^[%w_]+%s*:%s*(.+)$")
  if colon_type then
    return normalize_inline_whitespace(colon_type)
  end

  local _, bare_type = line:match("^([%w_,%s]+)%s+(.+)$")
  if bare_type then
    bare_type = normalize_inline_whitespace(bare_type)
    if looks_like_type(bare_type) then
      return bare_type
    end
  end

  if looks_like_type(line) then
    return line
  end
end

local function extract_type_candidate(lines)
  if not lines or #lines == 0 then
    return nil
  end

  local candidates = { lines[1] }
  if #lines > 1 then
    table.insert(candidates, table.concat(lines, " "))
  end

  for _, candidate in ipairs(candidates) do
    local type_text = extract_type_from_line(candidate)
    if type_text then
      return type_text
    end
  end
end

local function extract_inline_code(lines)
  for _, line in ipairs(lines) do
    local code = line:match("`([^`]+)`")
    if code then
      return normalize_inline_whitespace(code)
    end
  end
end

local function extract_type_from_hover(contents)
  local lines = hover_markdown_lines(contents)
  if #lines == 0 then
    return nil
  end

  local code_block = first_code_block(lines)
  if code_block then
    return extract_type_candidate(code_block) or first_nonempty_line(code_block)
  end

  return extract_type_candidate(lines) or extract_inline_code(lines)
end

local function set_type_registers(text)
  vim.fn.setreg('"', text, "v")
  return pcall(vim.fn.setreg, "+", text, "v")
end

function M.jump_in_current_window(jump)
  return function()
    jump()
  end
end

local function jump_with_target(jump, open_lsp_item_at_target)
  return function()
    local source_buf = vim.api.nvim_get_current_buf()
    local source_win = vim.api.nvim_get_current_win()
    local from = vim.fn.getpos(".")
    local tagname = vim.fn.expand("<cword>")

    from[1] = source_buf

    jump({
      on_list = function(options)
        if #options.items == 1 then
          open_lsp_item_at_target(options.items[1], source_buf, source_win, from, tagname)
          return
        end

        vim.fn.setqflist({}, " ", options)
        vim.cmd("botright copen")
      end,
    })
  end
end

function M.jump_in_other_window(jump)
  return jump_with_target(jump, open_lsp_item_in_other_window)
end

function M.jump_in_new_tab(jump)
  return jump_with_target(jump, open_lsp_item_in_new_tab)
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

function M.goto_definition_in_new_tab()
  if next(vim.lsp.get_clients({ bufnr = 0, method = "textDocument/definition" })) ~= nil then
    M.jump_in_new_tab(vim.lsp.buf.definition)()
    return
  end

  local source_buf = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()
  local source_cursor = vim.api.nvim_win_get_cursor(source_win)
  local target_win = prepare_new_tab(source_buf, source_win, source_cursor)
  if not target_win then
    return
  end

  vim.api.nvim_set_current_win(target_win)
  vim.cmd("normal! gd")
end

function M.copy_symbol_type()
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/hover" })
  local last_error

  if vim.tbl_isempty(clients) then
    vim.notify("No hover-capable LSP client attached", vim.log.levels.WARN)
    return
  end

  for _, client in ipairs(clients) do
    local response, err = client:request_sync(
      "textDocument/hover",
      util.make_position_params(win, client.offset_encoding),
      1000,
      bufnr
    )

    if err then
      last_error = string.format("%s hover request failed: %s", client.name, err)
    elseif response and response.result and response.result.contents then
      local type_text = extract_type_from_hover(response.result.contents)
      if type_text and type_text ~= "" then
        local copied_clipboard, clipboard_err = set_type_registers(type_text)
        if copied_clipboard then
          vim.notify(string.format("Copied type: %s", type_text), vim.log.levels.INFO)
        else
          vim.notify(
            string.format('Copied type to " but failed to update +: %s', clipboard_err),
            vim.log.levels.WARN
          )
        end
        return
      end
    end
  end

  if last_error then
    vim.notify(last_error, vim.log.levels.WARN)
    return
  end

  vim.notify("No type information available", vim.log.levels.WARN)
end

return M
