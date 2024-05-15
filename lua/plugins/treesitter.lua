return { 
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })()
    end,
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'c', 'cpp', 'css', 'bash', 'html', 'javascript', 'lua', 'typescript', 'python'
        };
        highlight = { enable = true, use_languagetree = true };
        rainbow = {
          enable = true,
          extended_mode = true,
          max_file_lines = nil,
        },
        refactor = {
          highlight_definitions = {
            enable = true,
            -- Set to false if you have an `updatetime` of ~100.
            clear_on_cursor_move = true,
          },
          -- highlight_current_scope = { enable = true },
        },
        indent = { enable = true },
        indent_on_enter = { enable = true };
        autopairs = { enable = true },
      }
    end
  },
  {"nvim-treesitter/nvim-treesitter-refactor"},
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require('treesitter-context').setup{}
    end
  }

}
