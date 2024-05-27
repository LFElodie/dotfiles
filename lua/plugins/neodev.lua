return {
  {
    "folke/neodev.nvim",
    event = 'BufRead',
    config = function()
      require("neodev").setup({
        library = { plugins = { "nvim-dap-ui" }, types = true },
      })
    end,
  },
}
