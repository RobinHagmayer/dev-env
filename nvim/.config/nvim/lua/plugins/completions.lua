-- Switched from mini.completion to blink.cmp for fuzzy matching, frecency-based
-- rankings, multi-source completion (LSP + path + snippets + buffer), signature help,
-- and cmdline completion. Uses the Rust fuzzy matcher (frizbee) which auto-downloads
-- a prebuilt binary when pinned to a release tag — no manual steps on new machines.
vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range(">=1.0") },
})

---@module 'blink.cmp'
---@type blink.cmp.Config
require("blink.cmp").setup({
  -- C-y to accept (similar to built-in completion), C-n/C-p to navigate
  keymap = { preset = "default" },

  appearance = {
    -- Match our Nerd Font Mono variant for aligned icons
    nerd_font_variant = "mono",
  },

  completion = {
    -- Only show docs when manually triggered (C-space)
    documentation = { auto_show = false },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  fuzzy = {
    -- Download prebuilt Rust binary from GitHub releases; fall back to Lua if unavailable
    implementation = "prefer_rust_with_warning",
  },
})
