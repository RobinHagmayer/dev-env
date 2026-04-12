vim.pack.add({
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main" -- Track main branch for latest parser and query updates
  },
})

-- Keep parsers in sync when the plugin is updated or installed
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('treesitter-pack-events', { clear = true }),
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and (ev.data.kind == 'update' or ev.data.kind == 'install') then
      vim.cmd('TSUpdate')
    end
  end
})

local languages = {
  "lua",
  "go",
  "python",
}

require'nvim-treesitter'.setup {
  -- Install to site dir so parsers survive config resets
  install_dir = vim.fn.stdpath('data') .. '/site'
}
require("nvim-treesitter").install(languages)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-start-highlight', { clear = true }),
  pattern = languages,
  callback = function()
    vim.treesitter.start()

    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo[0][0].foldmethod = 'expr'
    vim.wo[0][0].foldlevel = 999
  end,
})
