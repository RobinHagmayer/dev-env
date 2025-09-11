local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Easy exit from help
autocmd("FileType", {
  desc = "Close with <q>",
  group = augroup("RobinFileTypeHelp", { clear = true }),
  pattern = { "help" },
  callback = function(args)
    vim.keymap.set("n", "q", "<Cmd>quit<CR>", { buffer = args.buf })
  end,
})

-- Highlight on yank
autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = augroup("RobinHighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Disable automatic formatting for comments
autocmd("BufEnter", {
  desc = "Disable auto format for comments",
  group = augroup("RobinDisableFormatComments", { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Use 2 space indentation on these files
local two_space_filetypes = {
  "lua",
  "javascript",
  "typescript",
  "json",
  "yaml",
  "html",
  "css",
}
autocmd("FileType", {
  desc = "Use 2 space indentation on certain file types",
  group = augroup("RobinCustomIndent", { clear = true }),
  pattern = "*",
  callback = function(args)
    if vim.tbl_contains(two_space_filetypes, args.match) then
      vim.opt_local.tabstop = 2
      vim.opt_local.shiftwidth = 2
      vim.opt_local.softtabstop = 2
    end
  end,
})
