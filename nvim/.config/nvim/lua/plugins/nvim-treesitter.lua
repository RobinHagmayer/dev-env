return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', "go", 'html', "java", 'lua', 'luadoc', 'markdown', 'markdown_inline', "python", 'query', 'vim', 'vimdoc' },
      highlight = { enable = true },
      indent = { enable = true },
    },
}
