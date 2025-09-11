vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require("nvim-treesitter.configs").setup({
  auto_install = true,
  ensure_installed = {
    "bash",
    "css",
    "go",
    "html",
    "javascript",
    "json",
    "lua",
    "markdown",
    "python",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "luadoc",
  },
  sync_install = false,
  highlight = {
    enable = true,
    disable = "help",
  },
  indent = {
    enable = true,
  },
})
