return {
  "akinsho/toggleterm.nvim",
  version = "*",
  event = "VimEnter",
  keys = {
    { "<C-`>", desc = "Toggle active terminal" },
    { "<F12>", desc = "Toggle active terminal" },
    { "<leader>ta", desc = "Assign active terminal" },
    { "<leader>tf", desc = "Float terminal" },
    { "<leader>th", desc = "Horizontal terminal" },
    { "<leader>tv", desc = "Vertical terminal" },
    { "<leader>tg", desc = "Lazygit" },
    { "<leader>ts", "<cmd>TermSelect<CR>", desc = "Select terminal" },
    { "<leader>tt", desc = "Tab terminal (fullscreen)" },
  },
  opts = {
    open_mapping = [[<C-`>]],
    insert_mappings = false,
    terminal_mappings = false,
    direction = "float",
    float_opts = {
      border = "curved",
    },
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    local Terminal = require("toggleterm.terminal").Terminal
    local api = vim.api
    local lazygit = Terminal:new({
      cmd = "lazygit",
      direction = "float",
      hidden = true,
      float_opts = { border = "curved" },
    })

    local function ensure_terminal(count, direction, term_opts)
      local term = Terminal:new(vim.tbl_extend("force", {
        count = count,
        direction = direction,
      }, term_opts or {}))

      if not term.bufnr or not api.nvim_buf_is_valid(term.bufnr) then
        term:spawn()
      end

      return term
    end

    local function preload_terminals()
      if #api.nvim_list_uis() == 0 then
        return
      end

      ensure_terminal(1, "vertical")
      ensure_terminal(2, "float")
    end

    local map = vim.keymap.set
    local active_terminal = 1

    local function normalize_terminal_id(id)
      local terminal_id = math.floor(tonumber(id) or 1)
      if terminal_id < 1 then
        return 1
      end
      return terminal_id
    end

    local function set_active_terminal(id)
      active_terminal = normalize_terminal_id(id)
    end

    local function toggle_terminal(id, direction)
      local terminal_id = normalize_terminal_id(id)
      local command = terminal_id .. "ToggleTerm"
      if direction then
        command = command .. " direction=" .. direction
      end
      vim.cmd(command)
    end

    local function toggle_active_terminal()
      local count = vim.v.count
      if count > 0 then
        set_active_terminal(count)
        toggle_terminal(count)
        return
      end

      toggle_terminal(active_terminal)
    end

    vim.api.nvim_create_user_command("ToggleActiveTerminal", function()
      toggle_terminal(active_terminal)
    end, { desc = "Toggle active toggleterm terminal" })

    local function toggle(direction)
      return function()
        local terminal_id = vim.v.count1
        set_active_terminal(terminal_id)
        toggle_terminal(terminal_id, direction)
      end
    end
    local function assign_active_terminal()
      set_active_terminal(vim.v.count1)
    end

    map("n", "<C-`>", toggle_active_terminal, { desc = "Toggle active terminal" })
    map("n", "<F12>", toggle_active_terminal, { desc = "Toggle active terminal" })
    map("n", "<leader>ta", assign_active_terminal, { desc = "Assign active terminal" })
    map("n", "<leader>tf", toggle("float"), { desc = "Float terminal" })
    map("n", "<leader>th", toggle("horizontal"), { desc = "Horizontal terminal" })
    map("n", "<leader>tv", toggle("vertical"), { desc = "Vertical terminal" })
    map("n", "<leader>tt", toggle("tab"), { desc = "Tab terminal (fullscreen)" })
    map("n", "<leader>tg", function() lazygit:toggle() end, { desc = "Lazygit" })

    vim.schedule(preload_terminals)

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm#*",
      callback = function()
        local topts = { buffer = 0 }
        map("t", "<C-`>", [[<C-\><C-n><Cmd>ToggleActiveTerminal<CR>]], topts)
        map("t", "<F12>", [[<C-\><C-n><Cmd>ToggleActiveTerminal<CR>]], topts)
      end,
    })
  end,
}
