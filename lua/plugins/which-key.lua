return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- 懒加载，不影响启动速度
    config = function()
      require("which-key").setup({}) -- 默认配置已经够用
    end,
  }
}

