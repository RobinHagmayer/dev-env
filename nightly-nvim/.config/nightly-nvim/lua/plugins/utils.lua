vim.pack.add({
  { src = "https://github.com/nvim-tree/nvim-web-devicons" }, -- Icons
  { src = "https://github.com/j-hui/fidget.nvim" }, -- UI for Neovim notifications and LSP progress messages
})

require("fidget").setup()
