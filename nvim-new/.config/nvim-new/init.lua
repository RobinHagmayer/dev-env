local utils = require("utils")

require("config.globals")
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.usercmds")
-- require("config.diagnostics")

require("plugins.utils")
require("plugins.colorscheme")

if utils.has("rustup") then
  require("plugins.fff")
  require("plugins.completions")
end
require("plugins.lsp")
require("plugins.formatting")
require("plugins.nvim-treesitter")
