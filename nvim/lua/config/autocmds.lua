local cmdheight_group = vim.api.nvim_create_augroup("cmdheight", { clear = true })

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
  end,
})
