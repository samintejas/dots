return {
    -- AI
    {
        "nickjvandyke/opencode.nvim",
        version = "*", -- Latest stable release
        config = function()
            ---@type opencode.Opts
            vim.g.opencode_opts = {
                -- Keep the integrated server in a split while preserving the editing window.
                server = {
                    start = function()
                        vim.cmd("botright vsplit term://opencode --port | wincmd p")
                    end,
                },
            }

            local opencode = require("opencode")
            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { desc = desc })
            end

            -- Keep Ctrl-a/Ctrl-x available for native Vim motions and use one discoverable prefix.
            map({ "n", "x" }, "<leader>oa", function() opencode.ask("@this: ") end, "Ask about current context")
            map({ "n", "x" }, "<leader>os", opencode.select, "Select OpenCode action")
            map("n", "<leader>on", function() opencode.command("session.new") end, "New OpenCode session")
            map("n", "<leader>oi", function() opencode.command("session.interrupt") end, "Interrupt OpenCode")
            map("n", "<leader>oc", function() opencode.command("session.compact") end, "Compact OpenCode session")
            map("n", "<leader>ou", function() opencode.command("session.half.page.up") end, "Scroll OpenCode up")
            map("n", "<leader>od", function() opencode.command("session.half.page.down") end, "Scroll OpenCode down")

            vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
                { desc = "Append range to OpenCode", expr = true })
            vim.keymap.set("n", "goo", function() return opencode.operator("@this ") .. "_" end,
                { desc = "Append line to OpenCode", expr = true })
        end,
    },
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
            vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "#383838" })
            -- Dots: grey for structure, pink for selection / current item
            vim.api.nvim_set_hl(0, "CursorLine", { bg = "#111111" })
            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#f0a0dc" })
            vim.api.nvim_set_hl(0, "LineNr", { fg = "#8a8a8a" })
            vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#292929" })
            vim.api.nvim_set_hl(0, "Visual", { bg = "#383838" })
            vim.api.nvim_set_hl(0, "Search", { bg = "#383838", fg = "#f0a0dc" })
            vim.api.nvim_set_hl(0, "IncSearch", { bg = "#f0a0dc", fg = "#0a0a0a" })
            vim.api.nvim_set_hl(0, "Pmenu", { bg = "#181818" })
            vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#292929", fg = "#ececec" })
            vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#f2553f" })
            vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#f0b14a" })
            vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#6aa8ff" })
            vim.api.nvim_set_hl(0, "DiagnosticOk", { fg = "#5fcf7f" })
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
                    lualine_x = { require("opencode").statusline, "encoding", "fileformat", "filetype" },
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

    -- Fuzzy Finder.
    -- Replaces telescope + telescope-fzf-native: pure Lua, no `make` step, and
    -- it shells out to the real fzf binary rather than sorting in Lua.
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            "border-fused",
            winopts = { height = 0.85, width = 0.85, preview = { scrollbar = false } },
            files = { formatter = "path.filename_first" },
        },
    },

    -- Treesitter for syntax highlighting (main branch — Neovim 0.11+).
    -- The main branch does not support lazy-loading, hence lazy = false.
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local ensure = {
                "lua", "vim", "vimdoc",
                "javascript", "typescript", "tsx",
                "html", "css", "json", "yaml", "toml",
                "rust", "go", "gomod", "python", "bash",
                "markdown", "markdown_inline",
                "gitcommit", "regex", "sql",
            }
            require("nvim-treesitter").install(ensure)

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local ft = vim.bo[args.buf].filetype
                    local lang = vim.treesitter.language.get_lang(ft) or ft
                    if pcall(vim.treesitter.start, args.buf, lang) then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },

    -- Git integration
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "" },
                topdelete = { text = "" },
                changedelete = { text = "▎" },
                untracked = { text = "▎" },
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local map = function(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end
                map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
                map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
                map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
                map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
                map("n", "<leader>hb", function()
                    gs.blame_line({ full = true })
                end, "Blame line")
                map("n", "<leader>hd", gs.diffthis, "Diff this")
            end,
        },
    },

    -- Mason. Note the org: williamboman/* transferred to mason-org/* and the
    -- old paths only resolve through a GitHub redirect.
    {
        "mason-org/mason.nvim",
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        },
    },
    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                "rust_analyzer",
                "ts_ls",
                "jsonls",
                "gopls",
                "lua_ls",
                "html",
                "cssls",
                "emmet_ls",
                "pyright",
            },
            -- v2 enables every installed server on its own. Left off so the
            -- explicit vim.lsp.enable() below stays the single source of truth
            -- and servers are not enabled twice.
            automatic_enable = false,
        },
    },

    -- LSP. Neovim 0.11+ configures servers natively via vim.lsp.config /
    -- vim.lsp.enable; nvim-lspconfig is kept only for the server definitions
    -- it ships under lsp/.
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "saghen/blink.cmp",
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
        },
        config = function()
            local servers = {
                "lua_ls", "ts_ls", "html", "cssls", "emmet_ls",
                "rust_analyzer", "gopls", "pyright", "jsonls",
            }

            vim.lsp.config("*", {
                capabilities = require("blink.cmp").get_lsp_capabilities(),
                root_markers = { ".git" },
            })

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

            vim.lsp.config("rust_analyzer", {
                settings = {
                    ["rust-analyzer"] = {
                        checkOnSave = true,
                        check = { command = "clippy" },
                    },
                },
            })

            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        analyses = { unusedparams = true },
                        staticcheck = true,
                    },
                },
            })

            vim.lsp.config("emmet_ls", {
                filetypes = { "html", "css", "javascriptreact", "typescriptreact" },
            })

            vim.lsp.enable(servers)

            vim.diagnostic.config({
                virtual_text = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
                float = { source = true },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "󰅚 ",
                        [vim.diagnostic.severity.WARN]  = "󰀪 ",
                        [vim.diagnostic.severity.HINT]  = "󰌶 ",
                        [vim.diagnostic.severity.INFO]  = "󰋽 ",
                    },
                },
            })
        end,
    },

    -- Completion.
    -- Replaces nvim-cmp and its three source plugins: lsp/path/snippets/buffer
    -- are built in, and matching runs on every keystroke instead of debounced.
    {
        "saghen/blink.cmp",
        version = "1.*",
        event = "InsertEnter",
        dependencies = { "rafamadriz/friendly-snippets" },
        opts = {
            -- `enter` keeps <CR> as accept, matching the previous nvim-cmp setup.
            keymap = { preset = "enter" },
            appearance = { nerd_font_variant = "mono" },
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
            },
            sources = { default = { "lsp", "path", "snippets", "buffer" } },
            signature = { enabled = true },
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
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
            -- lsp_fallback was renamed to lsp_format.
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
        },
    },

    -- Essential editing plugins.
    -- Comment.nvim was dropped: unmaintained since Aug 2024, and Neovim has
    -- shipped native `gc`/`gcc` commenting since 0.10.
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
        opts = {},
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics" },
            { "<leader>xw", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
            { "<leader>xd", "<cmd>Trouble lsp toggle<cr>",                      desc = "LSP References / Definitions" },
            { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location List" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List" },
        },
    },
}
