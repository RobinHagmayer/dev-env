-- Switched from mini.completion to blink.cmp for fuzzy matching, frecency-based
-- rankings, multi-source completion (LSP + path + snippets + buffer), signature help,
-- and cmdline completion. Uses the Rust fuzzy matcher (frizbee) which auto-downloads
-- a prebuilt binary when pinned to a release tag — no manual steps on new machines.
vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range(">=1.0") },
  { src = "https://github.com/onsails/lspkind-nvim", name = "lspkind" },
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
    -- Always show docs when a completion item is selected
    documentation = { auto_show = true, auto_show_delay_ms = 250 },
    menu = {
      draw = {
        components = {
          -- Use lspkind icons for LSP kinds, nvim-web-devicons for Path completions
          kind_icon = {
            text = function(ctx)
              local icon = ctx.kind_icon
              if vim.tbl_contains({ "Path" }, ctx.source_name) then
                local dev_icon, _ = require("nvim-web-devicons").get_icon(ctx.label)
                if dev_icon then
                  icon = dev_icon
                end
              else
                icon = require("lspkind").symbol_map[ctx.kind] or ""
              end
              return icon .. ctx.icon_gap
            end,
            highlight = function(ctx)
              local hl = ctx.kind_hl
              if vim.tbl_contains({ "Path" }, ctx.source_name) then
                local _, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
                if dev_hl then
                  hl = dev_hl
                end
              end
              return hl
            end,
          },
        },
      },
    },
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  fuzzy = {
    -- Download prebuilt Rust binary from GitHub releases; fall back to Lua if unavailable
    implementation = "prefer_rust_with_warning",
  },
})