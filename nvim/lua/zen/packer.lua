vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function(use)
	  use 'wbthomason/packer.nvim'
	  use {
		  'nvim-telescope/telescope.nvim', tag = '0.1.8',
		  requires = { {'nvim-lua/plenary.nvim'} }
	  }
	  use "folke/tokyonight.nvim"

	  use('nvim-treesitter/nvim-treesitter',{run = ':TSUpdate'})
	  use {
		  'VonHeikemen/lsp-zero.nvim',
		  branch = 'v3.x',
		  requires = {
			  {'neovim/nvim-lspconfig'},
			  {'williamboman/mason.nvim'},
			  {'williamboman/mason-lspconfig.nvim'},
			  {'hrsh7th/nvim-cmp'},
			  {'hrsh7th/cmp-nvim-lsp'},
			  {'L3MON4D3/LuaSnip'},
		  }
	  }
  end)
