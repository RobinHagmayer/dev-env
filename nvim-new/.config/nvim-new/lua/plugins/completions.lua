vim.pack.add({
  { src = "https://github.com/Saghen/blink.cmp" },
})

require("blink.cmp").setup({
  -- 'default' for mappings similar to built-in completion
  keymap = { preset = "default" },

  appearance = {
    -- Sets the fallback highlight groups to nvim-cmp's highlight groups
    -- Useful for when your theme doesn't support blink.cmp
    use_nvim_cmp_as_default = true,
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    nerd_font_variant = "mono",
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  -- Experimental signature help support
  signature = { enabled = true, focusable = true },

  fuzzy = { implementation = "prefer_rust_with_warning" },

  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    menu = {
      draw = {
        treesitter = { "lsp" },
        columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" }, { "source_name" } },
        components = {
          source_name = { -- Custom component for showing source of completion (LSP or Buffer or ...)
            text = function(ctx)
              return "[" .. ctx.source_name .. "]"
            end,
            highlight = "BlinkCmpSource",
          },
        },
      },
    },
  },
})
