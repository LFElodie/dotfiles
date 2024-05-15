return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "pyright", "cmake"}, -- 确保安装 Lua 和 C++ 的 LSP 服务器
      })
      require("mason-null-ls").setup({
        ensure_installed = { "clang_format", "cppcheck", "black", "flake8", "cmake_format", "cmakelint" }, -- 确保安装必要的 linter 和 formatter
        automatic_setup = true,
      })
      require("mason-nvim-dap").setup({
        ensure_installed = { "cppdbg", "python" }, -- 确保安装必要的调试适配器
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

      -- 配置 C++ 语言服务器
      lspconfig.clangd.setup {
        capabilities = capabilities,
        cmd = { "clangd", "--compile-commands-dir=." }, -- 确保 clangd 使用正确的 compile_commands.json 目录
        root_dir = function()
          return vim.fn.getcwd()
        end,
        init_options = {
          compilationDatabasePath = "build", -- 指定 compile_commands.json 文件所在的目录
        }
      }
    end
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          -- For C++
          null_ls.builtins.formatting.clang_format,
          null_ls.builtins.diagnostics.cppcheck,

          -- For Python
          null_ls.builtins.formatting.black,
          null_ls.builtins.diagnostics.flake8,

          -- For CMake
          null_ls.builtins.formatting.cmake_format,
          null_ls.builtins.diagnostics.cmake_lint,
        },
      })
    end
  },
  {
    "jay-babu/mason-null-ls.nvim",
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
  
      -- C++ 配置
      dap.adapters.cppdbg = {
        id = 'cppdbg',
        type = 'executable',
        command = 'path/to/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
      }
      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
      }
  
      -- Python 配置
      dap.configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = function()
            return '/usr/bin/python3'
          end,
        },
      }
      -- 绑定快捷键
      vim.api.nvim_set_keymap('n', '<leader>b', ':lua require\'dap\'.toggle_breakpoint()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>c', ':lua require\'dap\'.continue()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>so', ':lua require\'dap\'.step_over()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>si', ':lua require\'dap\'.step_into()<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>su', ':lua require\'dap\'.step_out()<CR>', { noremap = true, silent = true })
    end
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
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
    end
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require('dap-python').setup('/usr/bin/python3')
    end
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
  }
}
