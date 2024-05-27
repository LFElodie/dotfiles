return {
  "akinsho/nvim-bufferline.lua",
  tag = "v4.5.2",
  event = 'BufWinEnter',
  dependencies = {
    "kyazdani42/nvim-web-devicons",
  },
  config = function()
    vim.opt.termguicolors = true
    require("bufferline").setup({})
  end,
}
