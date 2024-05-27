return {
  "terrortylor/nvim-comment",
  keys = {'gc', 'gcc'},
  config = function()
    require("nvim_comment").setup({
      create_mappings = true,
      comment_empty = false,
    })
  end,
}
