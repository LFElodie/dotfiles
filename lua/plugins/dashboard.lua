return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  config = function()
    require("dashboard").setup({
      -- config
      -- custom_header = {}
    })
  end,
  dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
