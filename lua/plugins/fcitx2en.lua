return {
  {
    "pysan3/fcitx5.nvim",
    cond = function()
      return vim.fn.executable("fcitx5-remote") == 1
    end,
    event = "ModeChanged",
    config = function()
      require("fcitx5").setup({
        imname = {
          norm = "keyboard-us",
          cmd = "keyboard-us",
        },
        remember_prior = true,
      })
    end,
  },
}
