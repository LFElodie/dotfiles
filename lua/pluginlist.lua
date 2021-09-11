local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

-- check if packer is installed (~/local/share/nvim/site/pack)
local packer_exists = pcall(vim.cmd, [[packadd packer.nvim]])

-- using { } when using a different branch of the plugin or loading the plugin with certain commands
require('packer').startup(function()
  -- packer
  use 'wbthomason/packer.nvim'

  -- completion
  use 'neovim/nvim-lspconfig'
  use 'nvim-lua/lsp_extensions.nvim'
  use 'onsails/lspkind-nvim'
  use 'nvim-treesitter/nvim-treesitter'
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'windwp/nvim-autopairs'
  -- Install nvim-cmp, and buffer source as a dependency
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets"
    }
  }

  use 'rhysd/vim-clang-format'

  -- git
  use 'tpope/vim-fugitive' -- Git commands in nvim
  -- Add git related info in the signs columns and popups
  use {
    'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } 
  } 

  -- tools
  use 'tpope/vim-commentary' -- "gc" to comment visual regions/lines
  use 'tpope/vim-surround' -- surroundings
  use'mg979/vim-visual-multi'
  -- use 'tpope/vim-sleuth' -- auto indent
  use 'tpope/vim-repeat' -- repeat
  use 'voldikss/vim-floaterm' -- Float term
  use 'terrortylor/nvim-comment'
  use 'christoomey/vim-tmux-navigator'
  use 'gruvbox-community/gruvbox'
  use 'ryanoasis/vim-devicons'
  use {
      'nvim-telescope/telescope.nvim',
      requires = {
          'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim',
          'nvim-telescope/telescope-fzy-native.nvim'
      }
  }
  use {
      'hoob3rt/lualine.nvim',
      requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }
  use {
    'akinsho/nvim-bufferline.lua', requires = 'kyazdani42/nvim-web-devicons'
  }

end)
