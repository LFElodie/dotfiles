-- plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-lua/popup.nvim",
    "nvim-telescope/telescope-fzy-native.nvim",
  },
  config = function()
    local ok_ts_parsers, ts_parsers = pcall(require, "nvim-treesitter.parsers")
    if ok_ts_parsers and ts_parsers.ft_to_lang == nil and vim.treesitter.language.get_lang ~= nil then
      ts_parsers.ft_to_lang = function(ft)
        return vim.treesitter.language.get_lang(ft) or ft
      end
    end

    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    local function get_find_command()
      if vim.fn.executable("rg") == 1 then
        return { "rg", "--files", "--color", "never" }
      end
      if vim.fn.executable("fd") == 1 then
        return { "fd", "--type", "f", "--color", "never" }
      end
      if vim.fn.executable("fdfind") == 1 then
        return { "fdfind", "--type", "f", "--color", "never" }
      end
      if vim.fn.executable("find") == 1 then
        return { "find", ".", "-type", "f" }
      end
      return nil
    end

    local function find_project_files(opts)
      opts = opts or {}
      local find_command = get_find_command()
      if not find_command then
        vim.notify(
          "Telescope find_files needs one of: rg, fd, fdfind, find",
          vim.log.levels.ERROR
        )
        return
      end

      opts.find_command = find_command
      builtin.find_files(opts)
    end

    telescope.setup({
      defaults = {
        file_sorter = require("telescope.sorters").get_fzy_sorter,
        color_devicons = true,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
        file_ignore_patterns = {
          "build",
          "dotbot",
          "pycache",
          "dev_venv",
          "zsh",
        },
        mappings = {
          i = {
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
      },
    })
    pcall(telescope.load_extension, "fzy_native")

    vim.keymap.set("n", "<leader>ss", find_project_files, { silent = true })
    vim.keymap.set("n", "<leader>sb", builtin.buffers, { silent = true })
    vim.keymap.set("n", "<leader>sf", find_project_files, { silent = true })
    vim.keymap.set("n", "<leader>sh", builtin.help_tags, { silent = true })
    vim.keymap.set("n", "<leader>sd", builtin.grep_string, { silent = true })
    vim.keymap.set("n", "<leader>sg", builtin.live_grep, { silent = true })
    vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { silent = true })
  end,
}
