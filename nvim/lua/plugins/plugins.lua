return {
	-- Colorschemes
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme oxocarbon]])  -- Set oxocarbon as the active colorscheme
			-- Set transparency for Normal and Floating windows
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
		end,
	},

	{ "folke/tokyonight.nvim", priority = 1000 },  -- Tokyo Night
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },  -- Catppuccin
	{ "neanias/everforest-nvim", priority = 1000 },  -- Everforest
	{ "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },  -- Moonfly


	-- neocolumn , lualine , treesitter , fuzzy finder

	{
		"ecthelionvi/NeoColumn.nvim",
		opts = {always_on = true}
	},
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons'},
		config = function()
			require("lualine").setup({
				options = {
					section_separators = '',
					component_separators = ''
				}
			})

		end,
	},
	{"nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query","java","go","markdown" },
			highlight = {
				enable = true
			}
		})
	end,
},
{
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x", -- Use the latest stable branch
	requires = { { "nvim-lua/plenary.nvim" } }, -- Dependency
	config = function()
		require("telescope").setup({
			defaults = {
				-- Default configuration for Telescope goes here:
				mappings = {
					i = {
						["<C-h>"] = "which_key" -- Use which-key in insert mode
					},
				},
			},
		})

		-- Key mappings for Telescope
		vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true })
		vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true })
		vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<CR>', { noremap = true, silent = true })
		vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<CR>', { noremap = true, silent = true })
	end,
},

-- lsp 

{
	"williamboman/mason.nvim",
	cmd = "Mason",
	config = function()
		require("mason").setup()
	end,
},
{
	"williamboman/mason-lspconfig.nvim",
	config = function()
		require("mason-lspconfig").setup({
			ensure_installed = { "gopls" },
		})
	end,
},

{
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require("lspconfig")

		lspconfig.gopls.setup({
			on_attach = function(client, bufnr)
				local opts = { noremap=true, silent=true }
				vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
				vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
				vim.cmd([[ autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync() ]])
			end,
			settings = {
				gopls = {
					analyses = {
						unusedparams = true,
					},
					staticcheck = true,
				},
			},
		})
	end,
},


-- auto completion

{
	"hrsh7th/nvim-cmp",
	config = function()
		local cmp = require("cmp")

		cmp.setup({
			snippet = {
				expand = function(args)
					-- snipping utility can be changed
					vim.fn["vsnip#anonymous"](args.body)
				end,
			},
			mapping = {
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.close(),
				["<CR>"] = cmp.mapping.confirm({ select = true }),
			},
			sources = {
				{ name = "nvim_lsp" },
				{ name = "buffer" },
				{ name = "path" },
				-- Add more sources as needed
			},
		})
	end,
},

{ "hrsh7th/cmp-nvim-lsp" },
{ "hrsh7th/cmp-buffer" },
{ "hrsh7th/cmp-path" },
{ "hrsh7th/vim-vsnip" },
}
