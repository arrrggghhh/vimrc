return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  ft = { "python", "go" },
  opts = {
    enabled = false,
    indent = {
      char = "╎",
      highlight = "IblIndent",
    },
    scope = {
      char = "╎",
      enabled = true,
      highlight = "IblScope",
      show_start = false,
      show_end = false,
    },
  },
  config = function(_, opts)
    local hooks = require("ibl.hooks")

    hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
    hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)

    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "IblIndent", { fg = "#4f4f63" })
      vim.api.nvim_set_hl(0, "IblScope", { fg = "#60607a" })
    end)

    require("ibl").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "python", "go" },
      callback = function(args)
        require("ibl").setup_buffer(args.buf, { enabled = true })
      end,
    })
  end,
}
