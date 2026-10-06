-- A separate app: :help $NVIM_APPNAME. Do not source the old config.
if vim.fn.has("nvim-0.12") == 0 then
  vim.notify(
    "nvim-modern requires Neovim 0.12+. Your normal nvim config is unchanged.",
    vim.log.levels.ERROR
  )
  return
end
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.no_plugin_maps = true
local tools_bin = vim.fn.stdpath("data") .. "/tools/node_modules/.bin"
if vim.fn.isdirectory(tools_bin) == 1 then
  vim.env.PATH = tools_bin .. ":" .. vim.env.PATH
end
require("editor.options")
local plugins_ok, plugins_err = pcall(require, "editor.plugins")
if not plugins_ok then
  vim.schedule(function()
    vim.notify("Plugin setup failed: " .. tostring(plugins_err), vim.log.levels.ERROR)
  end)
end
require("editor.guide").setup()
-- Ordinary feature modules; no custom plugin manager or dependency framework.
for _, feature in ipairs({
  "scroll-eof",
  "completion",
  "navigation",
  "treesitter",
  "lsp",
  "formatting",
  "editing",
}) do
  local ok, err = pcall(require, "editor." .. feature)
  if not ok then
    vim.schedule(function()
      vim.notify(feature .. ": " .. tostring(err) .. "\nSee :EditorHealth", vim.log.levels.ERROR)
    end)
  end
end
