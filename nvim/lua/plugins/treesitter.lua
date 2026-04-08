return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = {
      max_lines = 3,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local languages = {
        "go",
        "gomod",
        "gosum",
        "gotmpl",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "toml",
        "vim",
        "vimdoc",
      }
      local filetypes = {
        "go",
        "gomod",
        "gosum",
        "gotmpl",
        "json",
        "lua",
        "markdown",
        "python",
        "query",
        "toml",
        "vim",
      }
      local treesitter = require("nvim-treesitter")

      treesitter.setup({})
      if vim.fn.executable("tree-sitter") == 1 then
        local installed = treesitter.get_installed()
        local missing = vim.tbl_filter(function(lang)
          return not vim.list_contains(installed, lang)
        end, languages)

        if #missing > 0 then
          treesitter.install(missing)
        end
      end

      local group = vim.api.nvim_create_augroup("treesitter-filetypes", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = filetypes,
        callback = function()
          local ok = pcall(vim.treesitter.start)
          if not ok then
            return
          end
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
