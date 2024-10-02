require("nvim-treesitter.configs").setup({
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query","java","go","markdown" },
  highlight = {
      enable = true
  }
})
