require("blink.cmp").setup({
  keymap = { preset = "default" }, -- C-y accepts; Enter remains a newline.
  completion = {
    list = { selection = { preselect = false, auto_insert = false } },
    documentation = { auto_show = true, auto_show_delay_ms = 300 },
  },
  signature = { enabled = true },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  fuzzy = { implementation = "prefer_rust" }, -- Lua fallback without build setup.
})
require("editor.guide").add({
  id = "completion-help",
  title = "Completion controls",
  remind = true,
  help = "C-n/C-p select; C-y accepts; C-e cancels; C-space opens suggestions/docs; Tab moves through snippet fields.",
  run = function()
    vim.notify(
      "Completion: C-n/C-p select, C-y accepts, C-e cancels, C-space opens suggestions/docs. Enter is always a newline."
    )
  end,
})
