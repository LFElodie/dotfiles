local keymap = vim.api.nvim_set_keymap

-- clangformat {{{

keymap('n', '<leader>f', ':<c-u>ClangFormat<cr>', { noremap = true })
keymap('v', '<leader>f', ':ClangFormat<cr>', { noremap = true })

-- }}}

-- Completion menu symbols {{{

require('lspkind').init()

--}}}

-- nvim-cmp & ultisnips {{{
local cmp = require'cmp'
vim.g.UltiSnipsExpandTrigger = "<c-j>"

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  snippet = {
    expand = function(args)
      vim.fn['UltiSnips#Anon'](args.body)
    end
  },
  sources = {
    { name = "ultisnips"},
    { name = "nvim_lua"},
    { name = "nvim_lsp"},
    { 
      name = "buffer",
      opts = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end
      }
    },
    { name = "path"},
  },
  formatting = {
    format = function(entry, vim_item)
      -- fancy icons and a name of kind
      vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind

      -- set a name for each source
      vim_item.menu = ({
        ultisnips = "[Snippets]",
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[Lua]",
      })[entry.source.name]
      return vim_item
    end,
  },
  mapping = {
    ['<CR>'] = cmp.mapping.confirm(),
    ["<C-j>"] = cmp.mapping(function(fallback)
      if vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
        return vim.fn.feedkeys(t("<C-R>=UltiSnips#ExpandSnippet()<CR>"))
      elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
        return vim.fn.feedkeys(t("<C-R>=UltiSnips#JumpForwards()<CR>"))
      end
    end, {
      "i",
      "s",
    }),
    ["<C-k>"] = cmp.mapping(function(fallback)
      if vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
        return vim.fn.feedkeys(t("<C-R>=UltiSnips#JumpBackwards()<CR>"))
      end
    end, {
      "i",
      "s",
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if vim.fn.complete_info()["selected"] == -1 and vim.fn["UltiSnips#CanExpandSnippet"]() == 1 then
        vim.fn.feedkeys(t("<C-R>=UltiSnips#ExpandSnippet()<CR>"))
      elseif vim.fn["UltiSnips#CanJumpForwards"]() == 1 then
        vim.fn.feedkeys(t("<C-R>=UltiSnips#JumpForwards()<CR>"))
      elseif vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(t("<C-n>"), "n")
      elseif check_back_space() then
        vim.fn.feedkeys(t("<tab>"), "n")
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if vim.fn["UltiSnips#CanJumpBackwards"]() == 1 then
        return vim.fn.feedkeys(t("<C-R>=UltiSnips#JumpBackwards()<CR>"))
      elseif vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(t("<C-p>"), "n")
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  },
}

-- }}}

-- LSP {{{

  -- nvim-lspconfig
  local nvim_lsp = require('lspconfig')

-- on_attach and capabilities {{{
  local on_attach = function(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'v', '<leader>ca', '<cmd>lua vim.lsp.buf.range_code_action()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]], opts)
    -- vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
  end

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- }}}

-- Diagnostics {{{
  -- Diagnostic signs
  local signs = { Error = " ", Warning = " ", Hint = " ", Information = " " }

  for type, icon in pairs(signs) do
    local hl = "LspDiagnosticsSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end


  -- You will likely want to reduce updatetime which affects CursorHold
  -- note: this setting is global and should be set only once
  vim.o.updatetime = 250
  vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})]]

  -- Show diagnostics in source
  vim.lsp.handlers["textDocument/publishDiagnostics"] =
  function(_, _, params, client_id, _)
    local config = { -- your config
      underline = true,
      virtual_text = {
        prefix = "■ ",
        spacing = 4,
      },
      signs = true,
      update_in_insert = false,
    }
    local uri = params.uri
    local bufnr = vim.uri_to_bufnr(uri)

    if not bufnr then
      return
    end

    local diagnostics = params.diagnostics

    for i, v in ipairs(diagnostics) do
      diagnostics[i].message = string.format("%s: %s", v.source, v.message)
    end

    vim.lsp.diagnostic.save(diagnostics, bufnr, client_id)

    if not vim.api.nvim_buf_is_loaded(bufnr) then
      return
    end

    vim.lsp.diagnostic.display(diagnostics, bufnr, client_id, config)
  end
-- }}}

-- goto_definition {{{
local function goto_definition(split_cmd)
  local util = vim.lsp.util
  local log = require("vim.lsp.log")
  local api = vim.api

  local handler = function(_, method, result)
    if result == nil or vim.tbl_isempty(result) then
      local _ = log.info() and log.info(method, "No location found")
      return nil
    end

    if split_cmd then
      vim.cmd(split_cmd)
    end

    if vim.tbl_islist(result) then
      util.jump_to_location(result[1])

      if #result > 1 then
        util.set_qflist(util.locations_to_items(result))
        api.nvim_command("copen")
        api.nvim_command("wincmd p")
      end
    else
      util.jump_to_location(result)
    end
  end

  return handler
end

-- vim.lsp.handlers["textDocument/definition"] = goto_definition('split')

-- }}}

-- setup language servers {{{

-- cpp
nvim_lsp.ccls.setup ({
  on_attach = on_attach;
  capabilities = capabilities;
  init_options = {
    compilationDatabaseDirectory = "build";
    diagnostics = {
      onChange = 1;
    };
    cache = {
      directory = '/tmp/ccls-cache',
    };
  }
})

-- cmake
nvim_lsp.cmake.setup{}

-- python
nvim_lsp.pyright.setup({
  on_attach = on_attach;
  capabilities = capabilities;
})

-- }}}

-- }}}

-- treesitter & autopairs {{{

local npairs = require("nvim-autopairs")

npairs.setup({
    enable_check_bracket_line = false;
    ignored_next_char = "[%w%.]"; -- will ignore alphanumeric and `.` symbol
    check_ts = true,
    ts_config = {
        lua = {'string'},-- it will not add pair on that treesitter node
        javascript = {'template_string'},
        java = false,-- don't check treesitter on java
    }
})

local ts_config = require('nvim-treesitter.configs')

ts_config.setup {
  ensure_installed = {
    'c', 'cpp', 'css', 'bash', 'html', 'javascript', 'lua', 'typescript'
  };
  highlight = { enable = true, use_languagetree = true };
  indent = { enable = true },
  indent_on_enter = { enable = true };
  autopairs = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incmemental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

require("nvim-autopairs.completion.cmp").setup({
  map_cr = true, --  map <CR> on insert mode
  map_complete = true, -- it will auto insert `(` after select function or method item
  auto_select = true,  -- auto select first item
})

-- }}}
