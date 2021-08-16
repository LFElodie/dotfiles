local cmd = vim.cmd
local g = vim.g
local set = vim.api.nvim_set_option
local wset = vim.api.nvim_win_set_option
local keymap = vim.api.nvim_set_keymap

-- leader key
g.mapleader = ','

-- color scheme
vim.cmd[[colorscheme gruvbox]]

require 'basicsettings'
require 'pluginlist'
require 'treesitter'
require 'pluginssettings'
require 'completion'
require 'keybindings'

