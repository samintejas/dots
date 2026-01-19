return {
	-- AI
	{
		"github/copilot.vim",
		event = "InsertEnter",
		config = function()
			vim.g.copilot_no_tab_map = true
			vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false,
			})
			vim.g.copilot_filetypes = {
				["*"] = false,
				["javascript"] = true,
				["typescript"] = true,
				["lua"] = true,
				["rust"] = true,
				["go"] = true,
				["java"] = true,
				["python"] = true,
				["html"] = true,
				["css"] = true,
				["tsx"] = true,
			}
		end,
	},

	-- Colorscheme
	{
		"nyoom-engineering/oxocarbon.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme oxocarbon]])
			vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
			vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
			vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
		end,
	},

	-- Essential plugins
	{ "nvim-lua/plenary.nvim" },
	{ "nvim-tree/nvim-web-devicons" },

	-- UI Enhancements
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					globalstatus = true,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { { "filename", path = 1 } },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = { char = "│" },
			scope = { enabled = true },
		},
	},

	-- File Manager
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		opts = {
			open_for_directories = false,
			keymaps = {
				show_help = "<f1>",
			},
			floating_window_scaling_factor = 0.8,
		},
	},

	-- Fuzzy Finder
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
			})
			telescope.load_extension("fzf")
		end,
	},

	-- Treesitter for syntax highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"query",
					"javascript",
					"typescript",
					"tsx",
					"html",
					"css",
					"scss",
					"json",
					"jsonc",
					"yaml",
					"toml",
					"rust",
					"go",
					"gomod",
					"gosum",
					"gowork",
					"python",
					"dockerfile",
					"terraform",
					"hcl",
					"bash",
					"fish",
					"markdown",
					"markdown_inline",
					"xml",
					"graphql",
					"git_config",
					"git_rebase",
					"gitcommit",
					"gitignore",
					"gitattributes",
					"regex",
					"sql",
				},
				auto_install = true,
				highlight = {
					enable = true,
				},

				indent = { enable = true },

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
			})
		end,
	},

	-- Mason for installing LSP servers
	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"rust_analyzer",
					"ts_ls",
					"jsonls",
					"gopls",
					"lua_ls",
					"html",
					"cssls",
					"emmet_ls",
				},
			})
		end,
	},

	-- Native LSP config (Neovim 0.11+)
	{
		"neovim/nvim-lspconfig",
		config = function()
			config = function()
				local lspconfig = require("lspconfig")
				local capabilities = require("cmp_nvim_lsp").default_capabilities()
				local on_attach = function(client, bufnr)
					vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
				end

				vim.lsp.config("*", {
					capabilities = capabilities,
					on_attach = on_attach,
					root_markers = { ".git" },
				})

				-- Lua
				vim.lsp.config("lua_ls", {
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							diagnostics = { globals = { "vim" } },
							workspace = {
								checkThirdParty = false,
								library = vim.api.nvim_get_runtime_file("", true),
							},
							telemetry = { enable = false },
						},
					},
				})

				-- Rust
				vim.lsp.config("rust_analyzer", {
					settings = {
						["rust-analyzer"] = {
							checkOnSave = { command = "clippy" },
						},
					},
				})

				-- Go
				vim.lsp.config("gopls", {
					settings = {
						gopls = {
							analyses = { unusedparams = true },
							staticcheck = true,
						},
					},
				})

				-- Python
				vim.lsp.config("pyright", {})

				vim.lsp.config("jsonls", {})

				-- TypeScript / JavaScript (Next.js)
				vim.lsp.config("ts_ls", {
					capabilities = capabilities,
					on_attach = on_attach,
				})

				-- HTML for Next.js pages/app dirs
				vim.lsp.config("html", {
					capabilities = capabilities,
					on_attach = on_attach,
				})

				-- CSS (Tailwind works on top of this)
				vim.lsp.config("cssls", {
					capabilities = capabilities,
					on_attach = on_attach,
				})

				-- Emmet for JSX autofill
				vim.lsp.config("emmet_ls", {
					capabilities = capabilities,
					on_attach = on_attach,
					filetypes = { "html", "css", "javascriptreact", "typescriptreact" },
				})

				vim.lsp.enable({
					"lua_ls",
					"ts_ls",
					"html",
					"cssls",
					"emmet_ls",
					"rust_analyzer",
					"gopls",
					"pyright",
					"jsonls",
				})

				vim.diagnostic.config({
					virtual_text = true,
					underline = true,
					update_in_insert = false,
					severity_sort = true,
					float = {
						border = "rounded",
						source = "always",
					},
				})

				local signs = {
					Error = "󰅚 ",
					Warn = "󰀪 ",
					Hint = "󰌶 ",
					Info = "󰋽 ",
				}
				for type, icon in pairs(signs) do
					local hl = "DiagnosticSign" .. type
					vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
				end
			end
		end,
	},
	-- Completion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff" },
				rust = { "rustfmt" },
				go = { "gofumpt", "goimports" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				markdown = { "prettier" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},

	-- Essential editing plugins
	{
		"numToStr/Comment.nvim",
		opts = {},
	},
	{
		"echasnovski/mini.pairs",
		event = "VeryLazy",
		opts = {},
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		opts = {},
	},

	-- Helper plugins
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},

	-- Visual aids
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
	},
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			use_diagnostic_signs = true,
		},
		config = function(_, opts)
			require("trouble").setup(opts)
			vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>", { desc = "Toggle Trouble" })
			vim.keymap.set(
				"n",
				"<leader>xw",
				"<cmd>TroubleToggle workspace_diagnostics<cr>",
				{ desc = "Workspace Diagnostics" }
			)
			vim.keymap.set(
				"n",
				"<leader>xd",
				"<cmd>TroubleToggle document_diagnostics<cr>",
				{ desc = "Document Diagnostics" }
			)
			vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { desc = "Location List" })
			vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { desc = "Quickfix List" })
		end,
	},
}
