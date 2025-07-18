return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = 'BufRead',
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })()
    end,
    config = function()
      require("nvim-treesitter.configs").setup({
        auto_install = true,
        ensure_installed = {
          "c",
          "cpp",
          "css",
          "bash",
          "html",
          "javascript",
          "lua",
          "typescript",
          "python",
          "json",
          "yaml",
          "markdown",
          "cmake"
        },
        highlight = { enable = true, use_languagetree = true },
        refactor = {
          highlight_definitions = {
            enable = true,
            -- Set to false if you have an `updatetime` of ~100.
            clear_on_cursor_move = true,
          },
          -- highlight_current_scope = { enable = true },
        },
        indent = { enable = true },
        indent_on_enter = { enable = true },
      })
    end,
  },
  { "nvim-treesitter/nvim-treesitter-refactor" },
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
