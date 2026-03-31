vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function()
    vim.bo.formatprg = "jq ."
  end,
})
