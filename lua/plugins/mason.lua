return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "jay-babu/mason-null-ls.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "clangd", "pyright", "cmake" }, -- 确保安装 Lua 和 C++ 的 LSP 服务器
      })
      require("mason-null-ls").setup({
        ensure_installed = {
          "clang_format",
          "cppcheck",
          "black",
          "flake8",
          "cmake_format",
          "cmakelint",
          "stylua",
        }, -- 确保安装必要的 linter 和 formatter
        automatic_setup = true,
      })
      require("mason-nvim-dap").setup({
        ensure_installed = { "cppdbg", "python" }, -- 确保安装必要的调试适配器
      })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
    },
  }
}
