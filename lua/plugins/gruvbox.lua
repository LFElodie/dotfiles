return {
  {
    "gruvbox-community/gruvbox",
    lazy = false,
    priority = 1000,
    config = function()
      -- 不显式设置 background，让 Neovim 根据终端及系统外观自动切换。
      local function apply_contrast_overrides()
        if vim.g.colors_name ~= "gruvbox" then
          return
        end

        local light = vim.o.background == "light"
        vim.api.nvim_set_hl(0, "Visual", {
          fg = light and "#3c3836" or "#282828",
          bg = light and "#d79921" or "#fabd2f",
        })
        vim.api.nvim_set_hl(0, "VisualNOS", { link = "Visual" })
        vim.api.nvim_set_hl(0, "CursorLine", {
          bg = light and "#ebdbb2" or "#3c3836",
        })
      end

      local contrast_group = vim.api.nvim_create_augroup("GruvboxContrast", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = contrast_group,
        pattern = "gruvbox",
        callback = apply_contrast_overrides,
      })
      vim.api.nvim_create_autocmd("OptionSet", {
        group = contrast_group,
        pattern = "background",
        callback = function()
          -- 等主题响应 background 变化后再覆盖高亮。
          vim.schedule(apply_contrast_overrides)
        end,
      })

      vim.cmd.colorscheme("gruvbox")
      apply_contrast_overrides()
    end,
  },
}
