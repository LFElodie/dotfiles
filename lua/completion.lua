local keymap = vim.api.nvim_set_keymap

-- format {{{

-- ClangFormat
keymap('n', '<leader>f', ':<c-u>ClangFormat<cr>', { noremap = true })
keymap('v', '<leader>f', ':ClangFormat<cr>', { noremap = true })

-- yapf
keymap('n', '<leader>cf', ':<c-u>Yapf<cr>', { noremap = true })
keymap('v', '<leader>cf', ':Yapf<cr>', { noremap = true })

-- }}}

-- Completion menu symbols {{{

local lspkind = require('lspkind')

--}}}

vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""

-- nvim-cmp & snippets {{{
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local luasnip = require("luasnip")

local types = require("luasnip.util.types")

luasnip.config.setup({
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = {{"●", "GruvboxOrange"}}
			}
		},
		[types.insertNode] = {
			active = {
				virt_text = {{"●", "GruvboxBlue"}}
			}
		}
	},
})

local cmp = require("cmp")
require("luasnip/loaders/from_vscode").load()

cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noselect',
  },
  snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
    end
  },
  sources = {
    { name = "path"},
    { name = "copilot"},
    { name = "luasnip"},
    { name = "nvim_lua"},
    { name = "nvim_lsp"},
    { 
      name = "buffer",
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end
      }
    },
    { name = "path"},
  },
  formatting = {
    format = lspkind.cmp_format({
      with_text = true,
      menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[Snippets]",
        nvim_lua = "[Lua]",
      })
    }),
  },
  mapping = {
    ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
    ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
    ['<C-n>'] = cmp.mapping({
        c = function()
            if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
                vim.api.nvim_feedkeys(t('<Down>'), 'n', true)
            end
        end,
        i = function(fallback)
            if cmp.visible() then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
                fallback()
            end
        end
    }),
    ['<C-p>'] = cmp.mapping({
        c = function()
            if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
                vim.api.nvim_feedkeys(t('<Up>'), 'n', true)
            end
        end,
        i = function(fallback)
            if cmp.visible() then
                cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
            else
                fallback()
            end
        end
    }),
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
    ['<C-e>'] = cmp.mapping({ i = cmp.mapping.close(), c = cmp.mapping.close() }),
    ['<CR>'] = cmp.mapping({
        i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        c = function(fallback)
            if cmp.visible() then 
              local entry = cmp.get_selected_entry()
              if not entry then
                return fallback()
              end
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              vim.api.nvim_feedkeys(t('<CR>'), 'n', true)
            else
              fallback()
            end
            
        end,
    }),
    ["<C-j>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<C-k>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
        local copilot_keys = vim.fn["copilot#Accept"]("")
        if copilot_keys ~= "" then
            vim.api.nvim_feedkeys(copilot_keys, "i", true)
        else
            fallback()
        end
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  },
}

-- Use buffer source for `/`
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

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
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
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
    'c', 'cpp', 'css', 'bash', 'html', 'javascript', 'lua', 'typescript', 'python'
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

-- }}}
