return {
  {
    "mfussenegger/nvim-dap",
    cmd = {
        'DapToggleBreakpoint',
        'DapContinue',
        'DapStepInto',
        'DapStepOver',
        'DapStepOut',
        'DapTerminate',
    },
    keys = {
        { 'n', '<F5>', ':DapContinue<CR>' },
        { 'n', '<F9>', ':DapToggleBreakpoint<CR>' },
        { 'n', '<F10>', ':DapStepOver<CR>' },
        { 'n', '<F11>', ':DapStepInto<CR>' },
        { 'n', '<F12>', ':DapStepOut<CR>' },
    },
    ft = { 'python', 'lua', 'javascript', 'typescript', 'go', 'c', 'cpp' },
    config = function()
      local dap = require("dap")

      -- C++ 配置
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = "path/to/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
      }
      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }

      -- Python 配置
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          pythonPath = function()
            return "/usr/bin/python3"
          end,
        },
      }
      -- 绑定快捷键
      vim.api.nvim_set_keymap(
        "n",
        "<leader>b",
        ":lua require'dap'.toggle_breakpoint()<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>c",
        ":lua require'dap'.continue()<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>so",
        ":lua require'dap'.step_over()<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>si",
        ":lua require'dap'.step_into()<CR>",
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        "n",
        "<leader>su",
        ":lua require'dap'.step_out()<CR>",
        { noremap = true, silent = true }
      )
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
      local dap = require("dap")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        require("dapui").open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        require("dapui").close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        require("dapui").close()
      end
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup("/usr/bin/python3")
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
  },

}
