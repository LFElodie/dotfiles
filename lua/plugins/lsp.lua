return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyrefly", "clangd", "cmake", "lua_ls", "ruff"},
        -- 关闭自动启用，确保先注册自定义配置，再按预期启用服务器
        automatic_enable = false,
      })
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Python 工具链
          "debugpy",

          -- C++/ROS2 工具链
          "clangd",
          "clang-format", -- 格式化
          "cpplint",      -- 静态检查
        },
      })

    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig_util = require("lspconfig.util")
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      capabilities.textDocument = {
        synchronization = {
          didSave = true,
          dynamicRegistration = false,
        },
        signatureHelp = { dynamicRegistration = false }
      }

      -- 共用的 on_attach 函数
      local function on_attach(client, bufnr)
        -- 共用的按键设置
        vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, {buffer = bufnr})                    -- 查看文档
        vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, {buffer = bufnr})                   -- 跳转到定义
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, {buffer = bufnr})                      -- 跳转到定义
        vim.keymap.set("n", "gr", vim.lsp.buf.references, {buffer = bufnr})                      -- 查找引用
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {buffer = bufnr})             -- 代码操作
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {buffer = bufnr})                  -- 重命名
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, {buffer = bufnr}) -- 显示行诊断
      end

      -- 增强的 pyrefly 配置（专注类型检查）
      vim.lsp.config("pyrefly", {
        capabilities = capabilities,
        on_attach = on_attach,
      })
      vim.lsp.enable("pyrefly")

      -- Ruff (代码风格检查 + 格式化)
      vim.lsp.config("ruff", {
        on_attach = function(client, bufnr)
          -- 禁用 Ruff 的类型相关检查（交给 pyrefly）
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.documentFormattingProvider = true

          -- 绑定快捷键
          vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { buffer = bufnr })
          vim.keymap.set("v", "<leader>f", ":'<,'>!ruff format --line-length=140 -<CR>", { desc = "Ruff format selection" })
        end,
        init_options = {
          settings = {
            lineLength = 120,
            lint = {        -- lint 检查
              enabled = true,
              select = { "E", "F", "W", "I", "B", "D" },
              ignore = {"F841", "E501"}
            },
            format = {      -- 格式化／import 排序
              enable = true,
            },
          },
        },
      })
      vim.lsp.enable("ruff")

      -- C++ LSP 配置
      vim.lsp.config("clangd", {
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--compile-commands-dir=build", -- 关键：指向 Colcon 生成的 build 目录
          "--clang-tidy",
          "--completion-style=detailed",
        },
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          -- 优先识别 ROS2 工作空间标志，找不到时回退到当前文件目录
          on_dir(lspconfig_util.root_pattern(
            "src",
            "install",
            "build",
            "colcon.meta"
          )(fname) or vim.fs.dirname(fname))
        end,
        on_attach = on_attach,
      })
      vim.lsp.enable("clangd")

      vim.lsp.config("cmake", { capabilities = capabilities })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT", -- Neovim 用的是 LuaJIT
            },
            diagnostics = {
              globals = { "vim" }, -- 告诉语言服务器 `vim` 是全局变量
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false, -- 不再提示 "Do you want to configure your workspace as a lua project?"
            },
            hint = { enable = true },   -- 增加 inline suggestions (Neovim 0.10+)
            completion = { callSnippet = "Replace" },
            telemetry = {
              enable = false,
            },
          },
        },
      })
      vim.lsp.enable("lua_ls")

      -- 显式启用，避免被 mason-lspconfig 在默认配置下抢先启动
      vim.lsp.enable({
        "pyrefly",
        "ruff",
        "clangd",
        "cmake",
        "lua_ls",
      })

    end,
  },
  {
    'nvimdev/lspsaga.nvim',
    config = function()
        require('lspsaga').setup({})
    end,
    dependencies = {
        'nvim-treesitter/nvim-treesitter', -- optional
        'nvim-tree/nvim-web-devicons',     -- optional
    }
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- needs to be loaded in first
    config = function()
      require('tiny-inline-diagnostic').setup({
        options = {
          multilines = {
              -- Enable multiline diagnostic messages
              enabled = true,

              -- Always show messages on all lines for multiline diagnostics
              always_show = false,
          },
          show_source = {
            enabled = true,
            if_many = false,
          },
        }
      })
      vim.diagnostic.config({ virtual_text = false }) -- Only if needed in your configuration, if you already have native LSP diagnostics
    end
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
    opts = {},
  }
}
