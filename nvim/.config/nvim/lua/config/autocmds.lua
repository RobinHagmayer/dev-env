local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd('FileType', {
    group = augroup('close-with-q', { clear = true }),
    desc = 'Close with <q>',
    pattern = { 'help' },
    callback = function(args)
        vim.keymap.set('n', 'q', '<Cmd>quit<CR>', { buffer = args.buf })
    end,
})

-- Highlight on yank
autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end
})
