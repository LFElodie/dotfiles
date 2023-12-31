-- fugitive {{{

vim.api.nvim_set_keymap('n', '<leader>gs', [[<cmd>G<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gd', [[<cmd>Gvdiffsplit!<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gh', [[<cmd>diffget //2<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>gl', [[<cmd>diffget //3<CR>]], { noremap = true, silent = true })

-- }}}

-- Gitsigns {{{
require('gitsigns').setup {
  signs = {
    add = { hl = 'GitGutterAdd', text = '+' },
    change = { hl = 'GitGutterChange', text = '~' },
    delete = { hl = 'GitGutterDelete', text = '_' },
    topdelete = { hl = 'GitGutterDelete', text = '‾' },
    changedelete = { hl = 'GitGutterChange', text = '~' },
  },
  current_line_blame = true,
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    -- Actions
    map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line{full=true} end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

-- }}}

-- Telescope {{{
require('telescope').setup {
  defaults = {
    file_sorter = require('telescope.sorters').get_fzy_sorter,
    color_devicons = true,
    file_previewer = require('telescope.previewers').vim_buffer_cat.new,
    grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
    qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
    file_ignore_patterns = {
      "build",
      "dotbot"
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

-- }}}

-- Floaterm {{{

vim.g.floaterm_keymap_new = '<Leader>ft'
vim.g.floaterm_keymap_toggle = '<Leader>t'
vim.g.floaterm_position = 'bottom'

-- }}}

-- statusline {{{

vim.cmd [[packadd lualine.nvim]]

require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
    component_separators = {'', ''},
    section_separators = {'', ''},
    disabled_filetypes = {}
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {
      {
        'filename',
        file_status = true,
        path = 2,
      }
    },
    lualine_x = {
      'diff',
      'encoding', 
      'fileformat', 
      {
        'filetype', 
        colored = true
      }
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {}
}

-- }}}

-- bufferline {{{

vim.opt.termguicolors = true
require("bufferline").setup{
  options = {
    diagnostics = "nvim_lsp",
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      local s = " "
      for e, n in pairs(diagnostics_dict) do
        local sym = e == "error" and " "
        or (e == "warning" and " " or "" )
        s = s .. n .. sym
      end
      return s
    end,
  }
}



-- }}}

-- comment {{{

require('nvim_comment').setup({
  create_mappings = true;
  line_mapping = "<leader>cc";
  operator_mapping = "<leader>c";
  require('nvim_comment').setup({
  hook = function()
    if vim.api.nvim_buf_get_option(0, "filetype") == "cpp" then
      vim.api.nvim_buf_set_option(0, "commentstring", "// %s")
    end
  end
})

})


-- }}}

-- maximizer {{{

vim.api.nvim_set_keymap('n', '<leader>m', ":MaximizerToggle!<CR>", { noremap = true})

-- }}}

-- debug {{{

vim.api.nvim_set_keymap('n', '<leader>dd', ":call vimspector#Launch()<cr>", { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>de', ":call vimspector#Reset()<cr>", { noremap = true})

vim.api.nvim_set_keymap('n', '<leader>dl', ":call vimspector#StepInto()<cr>", { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>dj', ":call vimspector#StepOver()<cr>", { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>dk', ":call vimspector#StepOut()<cr>", { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>d_', ":call vimspector#Restart()<cr>", { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>d<space>', ":call vimspector#Continue()<cr>", { noremap = true})

vim.api.nvim_set_keymap('n', '<leader>drc', ":call vimspector#RunToCursor()<cr>", { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>dbp', ":call vimspector#ToggleBreakpoint()<cr>", { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>dcbp', ":call vimspector#ToggleAdvancedBreakpoint()<cr>", { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>dX', ":call vimspector#ClearBreakpoints()<cr>", { noremap = true})

vim.api.nvim_set_keymap('n', '<leader>di', "", { noremap = true})
vim.api.nvim_set_keymap('x', '<leader>di', "", { noremap = true})

-- }}}

-- indent blankline {{{

vim.opt.list = true
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}

vim.g.indent_blankline_char = '┊'
vim.g.indent_blankline_filetype_exclude = { 'help', 'packer' }
vim.g.indent_blankline_buftype_exclude = { 'terminal', 'nofile' }
vim.g.indent_blankline_char_highlight = 'LineNr'
vim.g.indent_blankline_show_trailing_blankline_indent = false

-- }}}

-- {{{

vim.g.mkdp_auto_close = 0
vim.g.mkdp_browser = '/usr/bin/microsoft-edge'

-- }}}
