-- FFF.nvim: fuzzy file finder and live grep with frecency, git status, and
-- constraints (git:modified, globs, negation). Uses a Rust core (zlob) for
-- fast globbing and fuzzy matching — prebuilt binary auto-downloads on install/update.
vim.pack.add({
  { src = "https://github.com/dmtrKovalenko/fff.nvim", version = vim.version.range(">=0.5") },
})

-- Download or build the Rust binary when the plugin is first installed or updated
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("fff-pack-events", { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == "fff.nvim" and (kind == "install" or kind == "update") then
      if not ev.data.active then
        vim.cmd.packadd("fff.nvim")
      end
      require("fff.download").download_or_build_binary()
    end
  end,
})

-- Lazy-sync: only start file indexing when the picker is opened (faster startup)
vim.g.fff = {
  lazy_sync = true,
  prompt = "󰍉  ", -- nf-md-magnify (\udb80\udf49)
}

vim.keymap.set("n", "<leader>ff", function()
  require("fff").find_files()
end, { desc = "FFF find files" })

vim.keymap.set("n", "<leader>fg", function()
  require("fff").live_grep()
end, { desc = "FFF live grep" })

vim.keymap.set("n", "<leader>fz", function()
  require("fff").live_grep({
    grep = { modes = { "fuzzy", "plain" } },
  })
end, { desc = "FFF fuzzy live grep" })

vim.keymap.set("n", "<leader>fc", function()
  require("fff").live_grep({ query = vim.fn.expand("<cword>") })
end, { desc = "FFF grep current word" })
