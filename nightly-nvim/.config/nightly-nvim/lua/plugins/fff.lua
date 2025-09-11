vim.pack.add({
  { src = "https://github.com/dmtrKovalenko/fff.nvim" }, -- Fuzzy file finder
})

require("fff").setup({
  debug = {
    enabled = true,
    show_scores = true,
  },
  prompt = " ",
})
vim.keymap.set("n", "<leader>ff", require("fff").find_files)
vim.keymap.set("n", "<leader>fg", require("fff").find_in_git_root)
