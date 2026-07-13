return {
  "akinsho/nvim-bufferline.lua",
  event = "BufWinEnter",
  dependencies = {
    "kyazdani42/nvim-web-devicons",
  },
  config = function()
    vim.opt.termguicolors = true

    local function gruvbox_highlights(defaults)
      if vim.g.colors_name ~= "gruvbox" then
        return {}
      end

      local light = vim.o.background == "light"
      local fill_bg = light and "#ebdbb2" or "#3c3836"
      local selected_bg = light and "#d79921" or "#fabd2f"
      local selected_fg = light and "#3c3836" or "#282828"
      local highlights = {
        fill = {
          fg = "#928374",
          bg = fill_bg,
        },
      }

      -- 当前文件使用完整色块标识，避免只靠一条细边线判断活动标签。
      for name in pairs(defaults.highlights) do
        if name == "tab_selected" or name:match("_selected$") then
          highlights[name] = {
            fg = selected_fg,
            bg = selected_bg,
            bold = true,
            italic = false,
            underline = false,
          }
        end
      end

      -- 分隔符沿用标签栏底色，让活动标签的边界保持清晰。
      highlights.separator_selected = {
        fg = fill_bg,
        bg = selected_bg,
      }
      highlights.tab_separator_selected = {
        fg = fill_bg,
        bg = selected_bg,
      }

      return highlights
    end

    require("bufferline").setup({
      options = {
        -- 允许明暗模式切换时覆盖已存在的 BufferLine 高亮组。
        themable = false,
      },
      highlights = gruvbox_highlights,
    })

    local background_group = vim.api.nvim_create_augroup("BufferlineBackgroundSync", { clear = true })
    vim.api.nvim_create_autocmd("OptionSet", {
      group = background_group,
      pattern = "background",
      callback = function()
        -- UI 可能在启动后才识别终端明暗；等主题重载完成后同步插件高亮。
        vim.schedule(function()
          if vim.g.colors_name then
            vim.api.nvim_exec_autocmds("ColorScheme", {
              pattern = vim.g.colors_name,
              modeline = false,
            })
            vim.cmd.redrawtabline()
          end
        end)
      end,
    })
  end,
}
