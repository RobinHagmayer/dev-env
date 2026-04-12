-- TODO: why mini.completion over nvim-cmp or vim.lsp.completion?
vim.pack.add({
  { src = "https://github.com/nvim-mini/mini.completion" },
})

require("mini.completion").setup()

