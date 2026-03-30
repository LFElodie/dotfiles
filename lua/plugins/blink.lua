return {
  {
    "Saghen/blink.cmp",
    event = "InsertEnter",
    version = '1.*',
    dependencies = {
      'rafamadriz/friendly-snippets',
      "fang2hou/blink-copilot"
    },
    opts = {
      keymap = {
        preset = "enter",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },
      },
      signature = { enabled = true },
      sources = {
        default = { "lsp", "path", "buffer", "snippets", "copilot"},
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
  }
}

