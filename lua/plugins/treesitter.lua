return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local group = vim.api.nvim_create_augroup("user_treesitter_setup", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = {
          "c",
          "cpp",
          "css",
          "sh",
          "html",
          "javascript",
          "lua",
          "typescript",
          "python",
          "json",
          "yaml",
          "markdown",
          "cmake",
        },
        callback = function(args)
          -- 新版 nvim-treesitter 由 Neovim 原生接口负责启动高亮
          pcall(vim.treesitter.start, args.buf)

          -- 缩进仍由 nvim-treesitter 提供，按文件类型启用即可
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        max_lines = 5,          -- 限制最大显示上下文行数
        multiline_threshold = 2 -- 超过多少行才展示
      })

    end,
  },
}
