return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      local has_pip = false
      local ensured_lsp_servers = { "clangd", "lua_ls" }
      if vim.fn.executable("python3") == 1 then
        vim.fn.system({ "python3", "-m", "pip", "--version" })
        has_pip = vim.v.shell_error == 0
      end
      if has_pip then
        table.insert(ensured_lsp_servers, "pyrefly")
        table.insert(ensured_lsp_servers, "cmake")
        table.insert(ensured_lsp_servers, "ruff")
      end

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = ensured_lsp_servers,
        -- 关闭自动启用，确保先注册自定义配置，再按预期启用服务器
        automatic_enable = false,
      })
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- Python 工具链
          { "debugpy", condition = function() return has_pip end },
          { "yapf", condition = function() return has_pip end },
          { "pyrefly", condition = function() return has_pip end },
          { "ruff", condition = function() return has_pip end },
          { "cmake", condition = function() return has_pip end },

          -- C++/ROS2 工具链
          "clangd",
          "clang-format", -- 格式化
          { "cpplint", condition = function() return has_pip end }, -- 静态检查
        },
        run_on_start = false,
      })

    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig_util = require("lspconfig.util")
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

      local function resolve_executable(cmd, extra_paths)
        local exepath = vim.fn.exepath(cmd)
        if exepath ~= "" then
          return exepath
        end

        if extra_paths then
          for _, dir in ipairs(extra_paths) do
            local candidate = dir .. "/" .. cmd
            if vim.fn.executable(candidate) == 1 then
              return candidate
            end
          end
        end

        local mason_candidate = mason_bin .. "/" .. cmd
        if vim.fn.executable(mason_candidate) == 1 then
          return mason_candidate
        end
      end

      local function enable_if_executable(server, cmd)
        if cmd then
          vim.lsp.enable(server)
        end
      end

      local function python_lsp_env()
        local env = vim.fn.environ()
        local venv = env.VIRTUAL_ENV or env.CONDA_PREFIX
        local configured_venv = env.NVIM_PYTHON_VENV
        local dev_env = vim.fn.expand("~/dev_env")

        if not venv or venv == "" then
          if configured_venv and configured_venv ~= "" then
            venv = vim.fn.expand(configured_venv)
          elseif vim.fn.isdirectory(dev_env) == 1 and vim.fn.executable(dev_env .. "/bin/python") == 1 then
            venv = dev_env
          end
        end

        if not venv or venv == "" then
          return nil
        end

        local path = venv .. "/bin"
        if env.PATH and env.PATH ~= "" then
          path = path .. ":" .. env.PATH
        end

        return {
          VIRTUAL_ENV = venv,
          PATH = path,
        }
      end

      local python_env = python_lsp_env()
      local python_paths = python_env and vim.split(python_env.PATH, ":", { trimempty = true }) or nil
      local yapf_cmd = resolve_executable("yapf", python_paths)
      local pyrefly_cmd = resolve_executable("pyrefly", python_paths)
      local ruff_cmd = resolve_executable("ruff", python_paths)

      local function is_under_path(path, root)
        local normalized_path = vim.fs.normalize(path)
        local normalized_root = vim.fs.normalize(root)
        return normalized_path == normalized_root or vim.startswith(normalized_path, normalized_root .. "/")
      end

      local function format_ros_python_with_yapf()
        local file = vim.api.nvim_buf_get_name(0)
        local ros_ws = vim.fn.expand("~/ros2_ws")
        local style = ros_ws .. "/.style.yapf"

        if not yapf_cmd then
          vim.notify("yapf not found. Install it in ~/dev_env or set NVIM_PYTHON_VENV.", vim.log.levels.WARN)
          return
        end

        if file == "" or not is_under_path(file, ros_ws) or vim.fn.filereadable(style) ~= 1 then
          vim.notify("ROS yapf style not found for this buffer. Restore ~/ros2_ws/.style.yapf first.", vim.log.levels.WARN)
          return
        end

        local view = vim.fn.winsaveview()
        vim.cmd("%!" .. vim.fn.shellescape(yapf_cmd) .. " --style=" .. vim.fn.shellescape(style))
        vim.fn.winrestview(view)
      end

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
        cmd = pyrefly_cmd and { pyrefly_cmd, "lsp" } or nil,
        on_attach = on_attach,
        cmd_env = python_env,
      })
      enable_if_executable("pyrefly", pyrefly_cmd)

      -- Ruff (代码风格检查 + 格式化)
      vim.lsp.config("ruff", {
        cmd = ruff_cmd and { ruff_cmd, "server" } or nil,
        on_attach = function(client, bufnr)
          -- 禁用 Ruff 的类型相关检查（交给 pyrefly）
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.documentFormattingProvider = false

          -- 绑定快捷键
          vim.keymap.set("n", "<leader>f", format_ros_python_with_yapf, { buffer = bufnr, desc = "YAPF format ROS Python" })
        end,
        init_options = {
          settings = {
            lineLength = 120,
            lint = {        -- lint 检查
              enabled = true,
              select = { "E", "F", "W", "I", "B", "D" },
              ignore = {"F841", "E501"}
            },
            format = {
              enable = false,
            },
          },
        },
      })
      enable_if_executable("ruff", ruff_cmd)

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
          local workspace_root = lspconfig_util.search_ancestors(vim.fs.dirname(fname), function(path)
            local has_src = vim.fn.isdirectory(path .. "/src") == 1
            local has_build = vim.fn.isdirectory(path .. "/build") == 1
            local has_install = vim.fn.isdirectory(path .. "/install") == 1
            local has_compile_commands = vim.fn.filereadable(path .. "/build/compile_commands.json") == 1
            local has_colcon_meta = vim.fn.filereadable(path .. "/colcon.meta") == 1

            -- ROS 2 工作空间需要定位到 ws 根目录，避免把单包目录误判成 root，
            -- 否则 --compile-commands-dir=build 会指向错误位置。
            if has_compile_commands or has_colcon_meta or (has_src and has_build and has_install) then
              return path
            end
          end)

          on_dir(
            workspace_root
            or lspconfig_util.root_pattern("compile_commands.json", ".clangd", ".git")(fname)
            or vim.fs.dirname(fname)
          )
        end,
        on_attach = on_attach,
      })
      enable_if_executable("clangd", "clangd")

      vim.lsp.config("cmake", { capabilities = capabilities })
      enable_if_executable("cmake", "cmake-language-server")

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
      enable_if_executable("lua_ls", "lua-language-server")

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
