return {
  "windwp/nvim-autopairs",
  config = function()
    require("nvim-autopairs").setup({
      enable_check_bracket_line = false,
      ignored_next_char = "[%w%.]", -- will ignore alphanumeric and `.` symbol
      check_ts = true,
      ts_config = {
        lua = { "string" }, -- it will not add pair on that treesitter node
        javascript = { "template_string" },
        java = false,   -- don't check treesitter on java
      },
    })
  end,
}
