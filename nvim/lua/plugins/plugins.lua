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
			ensure_installed = { "c", "lua", "vim", "vimdoc", "query","java","go","markdown" ,"html"},
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

-- LSP
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
            ensure_installed = { "gopls", "html", "lua_ls" },
        })
    end,
},
{
    "neovim/nvim-lspconfig",
    config = function()
        local lspconfig = require("lspconfig")
        
        -- Shared on_attach function
        local on_attach = function(client, bufnr)
            local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
            local opts = { noremap=true, silent=true }

            -- Enhanced keybindings
            buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
            buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
            buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
            buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
            buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
            buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
            buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
            buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
            buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
            buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
            buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
            buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
            buf_set_keymap('n', '<leader>dgn', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
            buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
            buf_set_keymap('n', '<leader>dll', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
        end

        -- gopls setup
        lspconfig.gopls.setup({
            on_attach = on_attach,
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                        shadow = true,
                    },
                    staticcheck = true,
                    gofumpt = true,
                },
            },
            init_options = {
                usePlaceholders = true,
            }
        })

        -- html setup
        lspconfig.html.setup({
            on_attach = on_attach,
        })

        -- lua_ls setup
        lspconfig.lua_ls.setup({
            on_attach = on_attach,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = {'vim'},
                    },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                },
            },
        })
    end,
},

-- Autocompletion and Snippets
{
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
    },
    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")

        require("luasnip.loaders.from_vscode").lazy_load()

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<CR>'] = cmp.mapping.confirm {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = true,
                },
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),
            sources = {
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'buffer' },
                { name = 'path' },
            },
        })
    end,
},

-- Autoformatter
{
    'stevearc/conform.nvim',
    opts = {},
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                go = {"gofmt", "goimports"},
                lua = { "stylua" },
                rust = { "rustfmt" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        })

        -- Override the default formatting function
        vim.lsp.buf.format = function(opts)
            conform.format(vim.tbl_extend("force", {
                lsp_fallback = true,
                async = false,
                timeout_ms = 500,
            }, opts or {}))
        end

        vim.keymap.set({"n","v"}, "<leader>fmt", function()
            vim.lsp.buf.format()
        end, {desc = "Format file or range in visual mode"})
    end,
}
}
