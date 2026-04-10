return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dr", function() require("dap").restart() end, desc = "Restart" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>df", function() require("dap").focus_frame() end, desc = "Focus current frame" },
      { "<leader>dj", function() require("dap").down() end, desc = "Stack frame down" },
      { "<leader>dk", function() require("dap").up() end, desc = "Stack frame up" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>dT", function()
        local ft = vim.bo.filetype
        if ft == "go" then
          require("dap-go").debug_test()
        elseif ft == "python" then
          require("dap-python").test_method()
        else
          vim.notify("No test runner for filetype: " .. ft, vim.log.levels.WARN)
        end
      end, desc = "Debug nearest test" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("dap-go").setup()

      local debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(debugpy_python)

      table.insert(dap.configurations.go, 1, {
        type = "go",
        name = "Debug (debug/main.go)",
        request = "launch",
        program = "${workspaceFolder}/debug",
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
        vim.keymap.set({ "n", "v" }, "K", function()
          dapui.eval()
        end, { desc = "DAP eval" })
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
        vim.keymap.del({ "n", "v" }, "K")
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
        vim.keymap.del({ "n", "v" }, "K")
      end
    end,
  },
}
