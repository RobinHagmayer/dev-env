return {
  {
    "futsuuu/vim-robot",
    -- lazy = false,
    -- priority = 1000,
    -- config = function()
    --   vim.cmd([[colorscheme robot]])
    -- end,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
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
    end,
  },
}
