return {
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

          -- For lua
          null_ls.builtins.formatting.stylua,
        },
      })
      vim.api.nvim_set_keymap(
        "n",
        "<leader>f",
        ":lua vim.lsp.buf.format({async=true})<CR>",
        { noremap = true, silent = true }
      )
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities =
          require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

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
        buf_set_keymap("n", "<leader>e", "<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts) -- 显示行诊断
        buf_set_keymap("n", "[d", "<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)                -- 上一个诊断
        buf_set_keymap("n", "]d", "<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)                -- 下一个诊断
        buf_set_keymap("n", "<space>q", "<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)        -- 在 loclist 中显示诊断
      end

      -- Python LSP 配置
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- C++ LSP 配置
      lspconfig.clangd.setup({
        capabilities = capabilities,
        cmd = { "clangd", "--compile-commands-dir=." },
        root_dir = lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
        on_attach = on_attach,
      })

      lspconfig.cmake.setup({ capabilities = capabilities })

      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })
    end,
  },
}
