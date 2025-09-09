return {

    -- Colorschemes

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

    { "neanias/everforest-nvim",   priority = 1000 },
    { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha", -- latte, frappe, macchiato, mocha
                transparent_background = true,
            })
        end,
    },
    { "folke/tokyonight.nvim",       priority = 1000 },


    -- Essential plugins
    { "nvim-lua/plenary.nvim", },
    { "nvim-tree/nvim-web-devicons", },

    -- UI Enhancements
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "catppuccin",
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
                    lualine_z = { "location" }
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

    -- no dashboard as it is unnecessary

    -- File Explorer
    ---@type LazySpec
    {
        "mikavilpas/yazi.nvim",
        event = "VeryLazy",
        dependencies = {
            -- check the installation instructions at
            -- https://github.com/folke/snacks.nvim
            "folke/snacks.nvim"
        },
        keys = {
            {
                "<c-up>",
                "<cmd>Yazi toggle<cr>",
                desc = "Resume the last yazi session",
            },
        },

        ---@type YaziConfig | {}
        opts = {
            -- if you want to open yazi instead of netrw, see below for more info
            open_for_directories = false,
            keymaps = {
                show_help = "<f1>",
            },
        },
        -- 👇 if you use `open_for_directories=true`, this is recommended
        init = function()
            -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
            -- vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
        end,
    },

    -- Fuzzy Finder
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
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
                    "lua", "vim", "vimdoc", "query",
                    "rust", "go", "typescript", "tsx", "javascript", "html", "css", "json",
                    "markdown", "markdown_inline"
                },
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = "<nop>",
                        node_decremental = "<bs>",
                    },
                },
            })
        end,
    },

    -- Git Integration
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
                untracked = { text = "┆" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "]h", function()
                    if vim.wo.diff then return "]h" end
                    vim.schedule(function() gs.next_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "Next hunk" })

                map("n", "[h", function()
                    if vim.wo.diff then return "[h" end
                    vim.schedule(function() gs.prev_hunk() end)
                    return "<Ignore>"
                end, { expr = true, desc = "Previous hunk" })

                -- Actions
                map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
                map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
                map("v", "<leader>hs", function() gs.stage_hunk { vim.fn.line("."), vim.fn.line("v") } end,
                    { desc = "Stage selected hunk" })
                map("v", "<leader>hr", function() gs.reset_hunk { vim.fn.line("."), vim.fn.line("v") } end,
                    { desc = "Reset selected hunk" })
                map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
                map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
                map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
                map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
                map("n", "<leader>hb", function() gs.blame_line { full = true } end, { desc = "Blame line" })
                map("n", "<leader>hd", gs.diffthis, { desc = "Diff This" })
                map("n", "<leader>hD", function() gs.diffthis("~") end, { desc = "Diff This ~" })
            end,
        },
    },

    -- LSP Configuration
    {
        "williamboman/mason.nvim",
        opts = {
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
        }
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "rust_analyzer",
                    "gopls",
                },
                automatic_installation = true,
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Configure LSP servers

            -- Lua
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                        telemetry = { enable = false },
                    },
                },
            })

            -- Go
            lspconfig.gopls.setup({
                capabilities = capabilities,
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
            })

            -- TypeScript/JavaScript (Next.js)
            -- lspconfig.ts_ls.setup({
            --     capabilities = capabilities,
            --     init_options = {
            --         preferences = {
            --             disableSuggestions = false,
            --         },
            --     },
            -- })

            -- HTML
            lspconfig.html.setup({
                capabilities = capabilities,
            })

            -- CSS
            lspconfig.cssls.setup({
                capabilities = capabilities,
            })

            -- Tailwind CSS
            lspconfig.tailwindcss.setup({
                capabilities = capabilities,
            })

            -- JSON
            lspconfig.jsonls.setup({
                capabilities = capabilities,
                settings = {
                    json = {
                        schemas = require("schemastore").json.schemas(),
                        validate = { enable = true },
                    },
                },
            })
        end,
    },

    -- Completion
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "saadparwaiz1/cmp_luasnip",
            "L3MON4D3/LuaSnip",
            "rafamadriz/friendly-snippets",
            "onsails/lspkind.nvim",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")

            -- Load snippets
            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "luasnip",  priority = 750 },
                    { name = "buffer",   priority = 500 },
                    { name = "path",     priority = 250 },
                }),
                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        maxwidth = 50,
                        ellipsis_char = "...",
                    }),
                },
            })

            -- Use buffer source for `/` and `?`
            cmp.setup.cmdline({ '/', '?' }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            -- Use cmdline & path source for ':'
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end,
    },

    -- Formatting and linting
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
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
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                javascript = { "eslint" },
                typescript = { "eslint" },
                javascriptreact = { "eslint" },
                typescriptreact = { "eslint" },
            }

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end,
    },

    -- Additional dependencies
    {
        "b0o/schemastore.nvim", -- JSON schemas for better JSON support
    },

    -- Essential editing plugins
    {
        "windwp/nvim-autopairs", -- Auto pairs for brackets, quotes, etc.
        event = "InsertEnter",
        opts = {
            check_ts = true,
        },
    },
    {
        "numToStr/Comment.nvim", -- Easy code commenting
        opts = {},
    },
    { 'echasnovski/mini.nvim', version = '*' },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
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

    -- Go-specific plugins
    {
        "ray-x/go.nvim",
        ft = "go",
        build = ':lua require("go.install").update_all_sync()',
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup({
                lsp_cfg = false, -- we use the separate lspconfig setup
                lsp_gofumpt = true,
                lsp_on_attach = function(_, bufnr)
                    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
                    local opts = { noremap = true, silent = true }

                    -- Go specific mappings
                    buf_set_keymap("n", "<leader>gt", "<cmd>GoTest<CR>", opts)
                    buf_set_keymap("n", "<leader>gtf", "<cmd>GoTestFunc<CR>", opts)
                    buf_set_keymap("n", "<leader>gi", "<cmd>GoImport<CR>", opts)
                    buf_set_keymap("n", "<leader>gI", "<cmd>GoImpl<CR>", opts)
                    buf_set_keymap("n", "<leader>ga", "<cmd>GoAlt<CR>", opts)
                end,
                trouble = true,
                test_runner = 'go',
                run_in_floaterm = true,
            })
        end
    },

    -- TypeScript/React specific plugins (continued)
    {
        "pmizio/typescript-tools.nvim",
        ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {
            settings = {
                -- spawn additional tsserver instance to calculate diagnostics on it
                separate_diagnostic_server = true,
                -- determine when the client asks the server about diagnostic
                publish_diagnostic_on = "insert_leave",
                -- specify commands exposed as code_actions
                expose_as_code_action = "all",
                tsserver_file_preferences = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                },
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
            vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
                { desc = "Workspace Diagnostics" })
            vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",
                { desc = "Document Diagnostics" })
            vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { desc = "Location List" })
            vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { desc = "Quickfix List" })
        end,
    },

    -- Additional utility plugins
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },
    {
        "RRethy/vim-illuminate",
        event = "BufReadPost",
        opts = {
            delay = 200,
            filetypes_denylist = {
                "dirbuf",
                "dirvish",
                "fugitive",
            },
        },
        config = function(_, opts)
            require("illuminate").configure(opts)

            -- Set highlighting
            vim.api.nvim_set_hl(0, "IlluminatedWordText", { link = "Visual" })
            vim.api.nvim_set_hl(0, "IlluminatedWordRead", { link = "Visual" })
            vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { link = "Visual" })
        end,
    },
    {
        "echasnovski/mini.pairs",
        event = "VeryLazy",
        opts = {},
    },

}
