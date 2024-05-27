return {
  {
    "hrsh7th/nvim-cmp",
    -- event = 'InsertEnter',
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-cmdline",
      "FelipeLema/cmp-async-path",
      "amarakon/nvim-cmp-buffer-lines",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require('luasnip')

      cmp.setup({
        completion = {
          completeopt = "menu,menuone,noselect",
        },
        sources = {
          { name = "async_path" },
          { name = "nvim_lua" },
          { name = "nvim_lsp" },
          { name = 'luasnip' },
          { name = "buffer-lines" },
          { name = "buffer", get_bufnrs = function() return vim.api.nvim_list_bufs() end },
          { name = "path" },
        },
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
            select = true,
          }),
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
        },
      })

      cmp.setup.cmdline({ "/", "?" }, { sources = { { name = "buffer" } } })
      cmp.setup.cmdline(":", { sources = { { name = "path" }, { name = "cmdline" } } })

    end,
  },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip").config.set_config({ history = true, updateevents = "TextChanged,TextChangedI" })
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  { "saadparwaiz1/cmp_luasnip" },
}
