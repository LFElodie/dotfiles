return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",
      "FelipeLema/cmp-async-path",
      "amarakon/nvim-cmp-buffer-lines",
    },
    config = function()

      local lspkind = require('lspkind')

      local t = function(str)
          return vim.api.nvim_replace_termcodes(str, true, true, true)
      end

      local cmp = require("cmp")

      cmp.setup {
        completion = {
          completeopt = 'menu,menuone,noselect',
        },
        sources = {
          { name = "async_path"},
          { name = "nvim_lua"},
          { name = "nvim_lsp"},
          { name = "buffer-lines"},
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
            ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), {'i', 'c'}),
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), {'i', 'c'}),
            ['<C-e>'] = cmp.mapping({ i = cmp.mapping.close(), c = cmp.mapping.close() }),
            ['<CR>'] = cmp.mapping({
                i = function(fallback)
                  if cmp.visible() and cmp.get_active_entry() then
                    cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                  else
                    fallback()
                  end
                end,
                s = cmp.mapping.confirm({ select = true }),
                c = function(fallback)
                    if cmp.visible() then
                        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
                    else
                        fallback()
                    end
                end
            }),
        },
      }

      -- Use buffer source for `/`
      cmp.setup.cmdline({'/', '?'}, {
        completion = { autocomplete = false },
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':'
      cmp.setup.cmdline(':', {
        completion = { autocomplete = false },
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
      local lspconfig = require("lspconfig")

      -- 使用 cmp_nvim_lsp 的 capabilities 配置 clangd
      lspconfig.clangd.setup {
        capabilities = capabilities,
        cmd = { "clangd", "--compile-commands-dir=." }, -- 确保 clangd 使用正确的 compile_commands.json 目录
        root_dir = function()
          return vim.fn.getcwd()
        end,
        init_options = {
          compilationDatabasePath = "build", -- 指定 compile_commands.json 文件所在的目录
        }
      }
      lspconfig.pyright.setup { capabilities = capabilities }
      lspconfig.cmake.setup { capabilities = capabilities }
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
              path = vim.split(package.path, ';'),
            },
            diagnostics = {
              globals = {'vim'},
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }
    end
  },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end
  },
  { "saadparwaiz1/cmp_luasnip" },
}
