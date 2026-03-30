local go_format_group = vim.api.nvim_create_augroup("go-format-on-save", { clear = false })
local go_filetype_group = vim.api.nvim_create_augroup("go-filetype-setup", { clear = true })

local function mason_binary(package, binary)
  local path = vim.fn.stdpath("data") .. "/mason/packages/" .. package .. "/" .. binary
  if vim.fn.executable(path) == 1 then
    return path
  end

  local system_binary = vim.fn.exepath(binary)
  if system_binary ~= "" then
    return system_binary
  end

  return nil
end

local function map_lsp_keys(bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
  end

  map("n", "gd", vim.lsp.buf.definition, "Go to definition")
  map("n", "gr", vim.lsp.buf.references, "List references")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "gy", function()
    if vim.fn.winnr("$") == 1 then
      vim.cmd("vsplit")
    else
      vim.cmd("wincmd w")
    end
    vim.lsp.buf.type_definition()
  end, "Type definition in split")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
end

local function split_lines(text)
  local lines = vim.split(text, "\n", { plain = true, trimempty = false })
  if lines[#lines] == "" then
    table.remove(lines, #lines)
  end
  return lines
end

local function run_goimports(bufnr)
  local goimports = mason_binary("goimports", "goimports")
  if not goimports then
    return false
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  if filename == "" then
    filename = vim.fn.getcwd() .. "/stdin.go"
  end

  local input = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
  if vim.bo[bufnr].endofline then
    input = input .. "\n"
  end

  local result = vim.system({ goimports, "-srcdir", filename }, {
    stdin = input,
    text = true,
  }):wait()

  if result.code ~= 0 then
    local message = result.stderr ~= "" and result.stderr or "goimports failed"
    vim.notify(message, vim.log.levels.WARN)
    return false
  end

  local formatted = split_lines(result.stdout)
  local current = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if vim.deep_equal(current, formatted) then
    return true
  end

  local view = vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
  vim.fn.winrestview(view)
  return true
end

local function organize_go_imports(bufnr)
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })[1]
  if not client then
    return
  end

  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = {
    only = { "source.organizeImports" },
    diagnostics = vim.diagnostic.get(bufnr),
  }

  local ok, response = pcall(client.request_sync, client, "textDocument/codeAction", params, 1000, bufnr)
  if not ok or not response or not response.result then
    return
  end

  for _, action in ipairs(response.result) do
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end

    if action.command then
      if client.exec_cmd then
        client:exec_cmd(action.command, { bufnr = bufnr })
      else
        vim.lsp.buf.execute_command(action.command)
      end
    end
  end
end

local function format_go_buffer(bufnr)
  vim.api.nvim_clear_autocmds({ group = go_format_group, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = go_format_group,
    buffer = bufnr,
    callback = function(args)
      if not run_goimports(args.buf) then
        organize_go_imports(args.buf)
        vim.lsp.buf.format({
          async = false,
          bufnr = args.buf,
          name = "gopls",
          timeout_ms = 2000,
        })
      end
    end,
  })
end

local function on_attach(client, bufnr)
  map_lsp_keys(bufnr)
end

return {
  {
    "mason-org/mason.nvim",
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      automatic_enable = false,
      ensure_installed = { "gopls" },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-e>"] = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local gopls = mason_binary("gopls", "gopls")

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded" },
        signs = true,
        underline = true,
        update_in_insert = false,
        virtual_text = true,
      })

      vim.lsp.config("gopls", {
        capabilities = capabilities,
        cmd = gopls and { gopls } or nil,
        on_attach = on_attach,
        root_markers = { "go.work", "go.mod", ".git" },
        settings = {
          gopls = {
            analyses = {
              shadow = true,
              unusedparams = true,
            },
            completeUnimported = true,
            staticcheck = true,
            usePlaceholders = true,
          },
        },
      })

      vim.lsp.enable("gopls")
      vim.api.nvim_create_autocmd("FileType", {
        group = go_filetype_group,
        pattern = "go",
        callback = function(args)
          vim.bo[args.buf].expandtab = false
          vim.bo[args.buf].tabstop = 4
          vim.bo[args.buf].shiftwidth = 4
          format_go_buffer(args.buf)
        end,
      })
    end,
  },
}
