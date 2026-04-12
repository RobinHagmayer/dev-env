vim.pack.add({
  { src = "https://github.com/rebelot/kanagawa.nvim" },
})

-- Setup color theme
require("kanagawa").setup({
  -- Transparent gutter background so it blends with the editor bg
  colors = {
    theme = {
      all = {
        ui = {
          bg_gutter = "none",
        },
      },
    },
  },
  -- Make end-of-buffer tilde match the non-text color (less visually noisy)
  overrides = function(colors)
    local theme = colors.theme
    return {
      EndOfBuffer = { fg = theme.ui.nontext },
    }
  end,
})
vim.cmd([[colorscheme kanagawa-wave]])
