vim.pack.add({
  { src = "https://github.com/rebelot/kanagawa.nvim" },
})

-- Setup color theme
require("kanagawa").setup({
  -- Changes themes
  colors = {
    theme = {
      all = {
        ui = {
          bg_gutter = "none",
        },
      },
    },
  },
  -- Changes colors
  overrides = function(colors)
    local theme = colors.theme
    return {
      EndOfBuffer = { fg = theme.ui.nontext },
    }
  end,
})
vim.cmd([[colorscheme kanagawa-wave]])
