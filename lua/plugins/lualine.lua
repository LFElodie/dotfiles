return {
  "hoob3rt/lualine.nvim",
  dependencies = {
    "kyazdani42/nvim-web-devicons",
  },
  config = function()
    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = "gruvbox",
        component_separators = { "", "" },
        section_separators = { "", "" },
        disabled_filetypes = {},
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "filename",
            file_status = true,
            path = 2,
          },
          {
            function()
              local clients = vim.lsp.get_clients({ bufnr = 0 })
              if not clients or #clients == 0 then
                return "No LSP"
              end
              local names = {}
              for _, client in ipairs(clients) do
                table.insert(names, client.name)
              end
              return " " .. table.concat(names, ", ")
            end,
            color = { fg = "#a6e3a1" },
          }
        },
        lualine_x = {
          "diff",
          "encoding",
          "fileformat",
          {
            "filetype",
            colored = true,
          },
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = {},
    })
  end,
}
