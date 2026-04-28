return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  ft = { "python", "go" },
  opts = {
    enabled = false,
    scope = {
      enabled = true,
      show_start = false,
      show_end = false,
    },
  },
  config = function(_, opts)
    require("ibl").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "python", "go" },
      callback = function(args)
        require("ibl").setup_buffer(args.buf, { enabled = true })
      end,
    })
  end,
}
