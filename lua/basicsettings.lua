-- General Settings {{{

  -- Make line numbers default
  vim.wo.number = true
  vim.wo.relativenumber = true

  -- Do not save when switching buffers
  vim.o.hidden = true

  -- Enable mouse mode
  vim.o.mouse = 'a'

  -- Enable break indent
  vim.o.breakindent = true

  vim.o.lazyredraw = true
  vim.o.belloff = 'all'

  -- Save undo history
  vim.o.undofile = true

  -- Decrease update time
  vim.o.updatetime = 250
  vim.wo.signcolumn = 'yes'

-- }}}

-- Appearance {{{

  -- Set highlight on search
  vim.o.hlsearch = true

  -- Cursor line
  vim.o.cursorline = true

  -- scroll off
  vim.o.scrolloff = 10

  -- Highlight on yank
  vim.api.nvim_exec(
  [[
  augroup YankHighlight
  autocmd!
  autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
  ]],
  false
  )

--  }}}

-- Searching {{{

  --Case insensitive searching UNLESS /C or capital in search
  vim.o.ignorecase = true
  vim.o.smartcase = true

-- }}}

-- Folding {{{

  vim.o.foldnestmax = 10
  vim.o.foldlevelstart = 0
  vim.o.foldmethod = 'marker'
  vim.o.foldenable = true

-- }}}


