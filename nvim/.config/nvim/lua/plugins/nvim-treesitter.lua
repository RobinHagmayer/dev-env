return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ensure_installed = {
      "astro",
      "bash",
      "c",
      "cpp",
      "css",
      "diff",
      "go",
      "html",
      "java",
      "javascript",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
    }

    require("nvim-treesitter.configs").setup({
      ensure_installed = ensure_installed,
      sync_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
    })
  end,
}
