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
        ensure_installed = { "pyright", "clangd", "cmake", "lua_ls", "ruff"},
        automatic_installation = true,
      })
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Python 工具链
          "pyright",
          "black",
          "debugpy",
          "ruff",

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
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 共用的 on_attach 函数
      local function on_attach(client, bufnr)
        local function buf_set_keymap(...)
          vim.api.nvim_buf_set_keymap(bufnr, ...)
        end
        local opts = { noremap = true, silent = true }

        -- 共用的按键设置
        buf_set_keymap("n", "<leader>k", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)                    -- 查看文档
        buf_set_keymap("n", "<C-]>", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)                   -- 跳转到定义
        buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)                      -- 跳转到定义
        buf_set_keymap("n", "gr", "<Cmd>lua vim.lsp.buf.references()<CR>", opts)                      -- 查找引用
        buf_set_keymap("n", "<leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)             -- 代码操作
        buf_set_keymap("n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)                  -- 重命名
        buf_set_keymap("n", "<leader>e", "<Cmd>lua vim.diagnostic.open_float()<CR>", opts) -- 显示行诊断
        buf_set_keymap("n", "[d", "<Cmd>lua vim.diagnostic.jump({count=-1, float=true})<CR>", opts)                -- 上一个诊断
        buf_set_keymap("n", "]d", "<Cmd>lua vim.diagnostic.jump({count=1, float=true})<CR>", opts)                -- 下一个诊断

        if client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
            buffer = bufnr,
            callback = vim.lsp.buf.clear_references,
          })
        end

      end

      -- 增强的 pyright 配置（专注类型检查）
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          pyright = {
            -- 使用 Ruff 的导入整理功能
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              -- 忽略 Ruff 已经处理的诊断类型
              diagnosticSeverityOverrides = {
                reportMissingImports = false,    -- Ruff 的 E402 已经处理
                reportUndefinedVariable = false, -- Ruff 的 F821 已经处理
              },
            },
          },
        },
      })

      -- Ruff (代码风格检查 + 格式化)
      lspconfig.ruff.setup({
        on_attach = function(client, bufnr)
          -- 禁用 Ruff 的类型相关检查（交给 Pyright）
          client.server_capabilities.hoverProvider = false

          -- 绑定快捷键
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true, filter = function(c) return c.name == "ruff" end })
          end, { buffer = bufnr, desc = "Format file with Ruff" })

          vim.keymap.set("v", "<leader>f", ":'<,'>!ruff format --line-length=140 -<CR>", { desc = "Ruff format selection" })
        end,
        init_options = {
          settings = {
            -- 启用 Ruff 的代码检查和格式化 (兼容 Black)
            args = {
              "--select=E,F,W,B,I,D",  -- 默认检查的规则
              "--ignore=E203,W503,F841,F401",    -- 忽略与 Black 冲突的规则
              "--line-length=140",      -- Black 默认行长度
              "--format=black",        -- 启用 Black 兼容格式化
              "--unfixable=F841,F401", -- 避免与 Pyright 冲突的修复
            },
          },
        },
      })

      -- C++ LSP 配置
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = {
          "clangd",
          "--background-index",
          "--compile-commands-dir=build", -- 关键：指向 Colcon 生成的 build 目录
          "--clang-tidy",
          "--completion-style=detailed",
        },
        root_dir = function(fname)
          -- 优先识别 ROS2 工作空间标志
          return lspconfig.util.root_pattern(
            "src",
            "install",
            "build",
            "colcon.meta"
          )(fname) or vim.fs.dirname(fname)
        end,
        on_attach = on_attach,
      })

      lspconfig.cmake.setup({ capabilities = capabilities })

      lspconfig.lua_ls.setup({
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
            telemetry = {
              enable = false,
            },
          },
        },
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
