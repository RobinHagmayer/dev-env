return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "VimEnter",
  opts = {
    appearance = {
      kind_icons = require("config.icons").symbol_kinds,
    },
    completion = { documentation = { auto_show = true } },
    fuzzy = {},
    keymap = { preset = "default" },
    signature = { enabled = true },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
  config = function(_, opts)
    local blink = require("blink.cmp")

    blink.setup(opts)

    -- Extend neovim's client capabilities with the completion ones.
    vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities(nil, true) })
  end,
  opts_extend = { "sources.default" },
}
