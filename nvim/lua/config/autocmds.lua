local cmdheight_group = vim.api.nvim_create_augroup("cmdheight", { clear = true })
local quickfix_group = vim.api.nvim_create_augroup("quickfix", { clear = true })

local function open_quickfix_entry(keep_focus)
  local quickfix_win = vim.api.nvim_get_current_win()
  local quickfix_cursor = vim.api.nvim_win_get_cursor(quickfix_win)
  local wininfo = vim.fn.getwininfo(quickfix_win)[1]

  if not wininfo or wininfo.quickfix ~= 1 then
    return
  end

  local command = wininfo.loclist == 1 and "ll" or "cc"
  local ok, err = pcall(vim.cmd, ("silent %s %d"):format(command, quickfix_cursor[1]))

  if not ok then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  if keep_focus and vim.api.nvim_win_is_valid(quickfix_win) then
    vim.api.nvim_set_current_win(quickfix_win)
    vim.api.nvim_win_set_cursor(quickfix_win, quickfix_cursor)
  end
end

vim.api.nvim_create_autocmd({ "VimEnter", "TabEnter", "TabNewEntered" }, {
  group = cmdheight_group,
  callback = function()
    vim.cmd("set cmdheight=1")
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.bo.formatprg = "jq ."
    vim.bo.equalprg = "jq ."
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = quickfix_group,
  pattern = "qf",
  callback = function(args)
    vim.keymap.set("n", "<CR>", function()
      open_quickfix_entry(true)
    end, { buffer = args.buf, desc = "Open quickfix entry and keep focus", silent = true })
    vim.keymap.set("n", "o", function()
      open_quickfix_entry(false)
    end, { buffer = args.buf, desc = "Open quickfix entry", silent = true })
  end,
})
