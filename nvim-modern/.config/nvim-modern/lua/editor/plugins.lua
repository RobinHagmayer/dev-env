-- :help vim.pack and vim.pack-events. Hooks MUST precede the first add.
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.kind == "delete" then
      return
    end
    if ev.data.spec.name == "fff" then
      vim.cmd.packadd("fff")
      local ok, err = pcall(function()
        require("fff.download").download_or_build_binary()
      end)
      if not ok then
        vim.notify("FFF binary: " .. tostring(err), vim.log.levels.ERROR)
      end
    elseif ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
      vim.schedule(function()
        vim.cmd.packadd("nvim-treesitter")
        require("nvim-treesitter").update()
      end)
    end
  end,
})
vim.pack.add({
  { src = "https://github.com/dmtrKovalenko/fff", version = "main" },
  { src = "https://github.com/nvim-mini/mini.nvim", version = "main" },
  { src = "https://github.com/folke/which-key.nvim", version = "main" },
  { src = "https://github.com/neovim/nvim-lspconfig", version = "master" },
  { src = "https://github.com/mason-org/mason.nvim", version = "main" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim", version = "main" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  -- Latest released completion line. V2 explicitly warns of breaking changes.
  { src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("1") },
  { src = "https://github.com/rafamadriz/friendly-snippets", version = "main" },
  { src = "https://github.com/stevearc/conform.nvim", version = "master" },
  { src = "https://github.com/rebelot/kanagawa.nvim", version = "master" },
}, { confirm = false })
require("kanagawa").setup({})
vim.cmd.colorscheme("kanagawa-wave")
require("mini.icons").setup()
require("mini.pick").setup()
require("mini.extra").setup()
vim.ui.select = require("mini.pick").ui_select
require("which-key").setup({ delay = 350 })
require("which-key").add({
  { "<leader>f", group = "find" },
  { "<leader>c", group = "code" },
  { "<leader>h", group = "help / discover" },
  { "<leader>t", group = "syntax editing" },
  { "<leader>u", group = "updates / tools" },
})
