vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

local utils = require("utils")

local conditional_languages = {
  { name = "go", checker = "go" },
  { name = "javascript", checker = "node" },
  { name = "python", checker = "python3" },
  { name = "typescript", checker = "node" },
  { name = "tsx", checker = "node" },
}

local always_install = {
  "bash",
  "css",
  "html",
  "json",
  "lua",
  "markdown",
  "vim",
  "vimdoc",
  "luadoc",
}

local ensure_installed = {}

for _, lang in ipairs(always_install) do
  table.insert(ensure_installed, lang)
end

for _, lang in ipairs(conditional_languages) do
  if utils.has(lang.checker) then
    table.insert(ensure_installed, lang.name)
  end
end

require("nvim-treesitter").install(ensure_installed)

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function()
    vim.api.nvim_command("TSUpdate")
  end,
})

-- require("nvim-treesitter.configs").setup({
--   auto_install = true,
--   ensure_installed = ensure_installed,
--   sync_install = false,
--   highlight = {
--     enable = true,
--     disable = "help",
--   },
--   indent = {
--     enable = true,
--   },
-- })
