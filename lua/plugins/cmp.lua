return {
  {
    "hrsh7th/nvim-cmp",
    event = 'InsertEnter',
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-cmdline",
      "FelipeLema/cmp-async-path",
      "amarakon/nvim-cmp-buffer-lines",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require('luasnip')

      cmp.setup({
        completion = {
          completeopt = "menu,menuone,noselect",
        },
        experimental = {
          ghost_text = true,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- 添加 snippet 引擎支持
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },    -- 提高 LSP 优先级
          { name = "luasnip",  priority = 900 },    -- snippet 优先于其他
          { name = "async_path", priority = 800 },
          { name = "nvim_lua", priority = 700 },
          { name = "buffer", priority = 600},  -- 增加触发长度减少干扰
          { name = "buffer-lines", priority = 500 },
          { name = "nvim_lsp_signature_help" },     -- 保持默认优先级
          { name = "path" },
        }),
        mapping = {
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { 'i', 's' }),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete({
            config = {
              sources = { -- 空格补全时只启用特定源
                { name = "nvim_lsp" },
                { name = "luasnip" },
              }
            }
          }),
          ["<C-e>"] = cmp.mapping.close(),
        },
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(), -- 解决 <Tab> 等键位问题
        sources = {
          { name = "buffer" }
        }
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "path" },
          { name = "cmdline" },
        }
      })

    end,
  },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip").config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged", -- 添加删除检查
      })
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
