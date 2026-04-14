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
    local api = vim.api
    local terminals = require("toggleterm.terminal")
    local Terminal = terminals.Terminal

    local function is_toggleterm_buffer(bufnr)
      return vim.bo[bufnr].filetype == "toggleterm" or vim.b[bufnr].toggle_number ~= nil
    end

    local user_on_open = opts.on_open
    opts.on_open = function(term)
      if user_on_open then
        user_on_open(term)
      end

      vim.schedule(function()
        if not term.window or not api.nvim_win_is_valid(term.window) then
          return
        end

        if api.nvim_get_current_win() ~= term.window then
          return
        end

        if not is_toggleterm_buffer(api.nvim_win_get_buf(term.window)) then
          return
        end

        if api.nvim_get_mode().mode:sub(1, 1) ~= "t" then
          vim.cmd("startinsert")
        end
      end)
    end

    require("toggleterm").setup(opts)

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
    local terminal_directions = {
      [1] = "vertical",
      [2] = "float",
    }

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

    local function remember_terminal_direction(id, direction)
      if direction then
        terminal_directions[normalize_terminal_id(id)] = direction
      end
    end

    local function get_terminal_direction(id, direction)
      local terminal_id = normalize_terminal_id(id)
      local term = terminals.get(terminal_id, true)
      local resolved_direction = direction or (term and term.direction) or terminal_directions[terminal_id] or opts.direction

      if resolved_direction then
        terminal_directions[terminal_id] = resolved_direction
      end

      return resolved_direction
    end

    local function get_or_create_terminal(id, direction)
      local terminal_id = normalize_terminal_id(id)
      local resolved_direction = get_terminal_direction(terminal_id, direction)
      local term = terminals.get(terminal_id, true)

      if term then
        return term, resolved_direction
      end

      return ensure_terminal(terminal_id, resolved_direction), resolved_direction
    end

    local function toggle_terminal(id, direction)
      local term, resolved_direction = get_or_create_terminal(id, direction)
      local is_open = term:is_open()

      term:toggle(nil, resolved_direction)

      if not is_open then
        remember_terminal_direction(term.id, resolved_direction)
      end
    end

    local function get_visible_terminals()
      local visible = {}
      local seen = {}

      for _, win in ipairs(api.nvim_tabpage_list_wins(api.nvim_get_current_tabpage())) do
        local buf = api.nvim_win_get_buf(win)

        if is_toggleterm_buffer(buf) then
          local term_id = vim.b[buf].toggle_number
          local term = term_id and terminals.get(term_id, true)

          if term and term:is_open() and not seen[term.id] then
            seen[term.id] = true
            table.insert(visible, term)
          end
        end
      end

      return visible
    end

    local function switch_terminal(id)
      local terminal_id = normalize_terminal_id(id)
      local term, resolved_direction = get_or_create_terminal(terminal_id)

      for _, visible_term in ipairs(get_visible_terminals()) do
        visible_term:close()
      end

      term:open(nil, resolved_direction)
      remember_terminal_direction(terminal_id, resolved_direction)
    end

    local function toggle_active_terminal()
      local count = vim.v.count
      if count > 0 then
        set_active_terminal(count)
        switch_terminal(count)
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
