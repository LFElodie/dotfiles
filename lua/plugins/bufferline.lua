return {
  "akinsho/nvim-bufferline.lua",
  event = 'BufWinEnter',
  dependencies = {
    "kyazdani42/nvim-web-devicons",
  },
  config = function()
    vim.opt.termguicolors = true
    require("bufferline").setup({})
  end,
}
