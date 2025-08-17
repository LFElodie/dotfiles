local G = require("G")
return {
  "voldikss/vim-floaterm",
  keys = {
    -- 全局 toggle
    { "<leader>t", "<cmd>FloatermToggle<CR>", desc = "Toggle Floaterm", mode = { "n", "t" } },
  },
}
