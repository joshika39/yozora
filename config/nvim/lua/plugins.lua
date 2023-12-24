local status, packer = pcall(require, 'packer')
if (not status) then
  print("Packer is not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  -- Packer
  use 'wbthomason/packer.nvim'

  -- Visuals
  use {
    'svrana/neosolarized.nvim',
    requires = { 'tjdevries/colorbuddy.nvim' }
  }
  use 'hoob3rt/lualine.nvim'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'norcalli/nvim-colorizer.lua'
  use 'kyazdani42/nvim-web-devicons'

  -- LSPs and complition
  use 'neovim/nvim-lspconfig'
  use 'onsails/lspkind-nvim'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp'
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'MunifTanjim/prettier.nvim'
  use 'nvimdev/lspsaga.nvim'
  -- Helpers
  use 'windwp/nvim-autopairs'
  use 'windwp/nvim-ts-autotag'
  use 'akinsho/nvim-bufferline.lua'

  -- Mason
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'

  --Snippets
  use 'L3MON4D3/LuaSnip'

  -- File browsers
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'nvim-telescope/telescope-file-browser.nvim'

  -- Git
  use 'lewis6991/gitsigns.nvim'
  use 'dinhhuy258/git.nvim'
end)
