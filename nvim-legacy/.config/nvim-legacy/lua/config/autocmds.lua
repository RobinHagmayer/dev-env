local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Close help/quickfix windows with 'q'
autocmd("FileType", {
  desc = "Close special buffers with q",
  group = augroup("close-with-q", { clear = true }),
  pattern = { "help", "qf", "man", "lspinfo" },
  callback = function(args)
    vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = args.buf, silent = true })
  end,
})

-- Disable auto comment continuation
autocmd("BufEnter", {
  desc = "Disable auto format for comments",
  group = augroup("no-auto-comment", { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})
