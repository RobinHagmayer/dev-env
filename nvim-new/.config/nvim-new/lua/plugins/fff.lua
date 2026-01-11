vim.pack.add({
  { src = "https://github.com/dmtrKovalenko/fff.nvim" }, -- Fuzzy file finder
})

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(event)
    if event.data.updated then
      require("fff.download").download_or_build_binary()
    end
  end,
})

vim.g.fff = {
  lazy_sync = true,
  prompt = " ",
  debug = {
    enabled = true,
    show_scores = true,
  },
}

vim.keymap.set("n", "<leader>ff", require("fff").find_files, { desc = "FFFind files" })
vim.keymap.set("n", "<leader>fg", require("fff").find_in_git_root, { desc = "FFFind git files" })
