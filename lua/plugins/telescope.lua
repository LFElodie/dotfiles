-- plugins/telescope.lua
return {
    'nvim-telescope/telescope.nvim', 
    tag = '0.1.6',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-lua/popup.nvim', 
      'nvim-telescope/telescope-fzy-native.nvim'
    },
    config = function()
      require('telescope').setup {
        defaults = {
          file_sorter = require('telescope.sorters').get_fzy_sorter,
          color_devicons = true,
          file_previewer = require('telescope.previewers').vim_buffer_cat.new,
          grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
          qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
          file_ignore_patterns = {
            "build",
            "dotbot",
            "pycache"
          },
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      }
      require('telescope').load_extension('fzy_native')

      vim.api.nvim_set_keymap('n', '<leader>ss', [[<cmd>lua require('telescope.builtin').file_browser()<CR>]], { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>sb', [[<cmd>lua require('telescope.builtin').buffers()<CR>]], { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>sf', [[<cmd>lua require('telescope.builtin').find_files()<CR>]], { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>sh', [[<cmd>lua require('telescope.builtin').help_tags()<CR>]], { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>sd', [[<cmd>lua require('telescope.builtin').grep_string()<CR>]], { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>sg', [[<cmd>lua require('telescope.builtin').live_grep()<CR>]], { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<leader>/', [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]], { noremap = true, silent = true })
    end,
}
