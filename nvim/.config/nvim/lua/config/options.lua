local opt = vim.opt

-- Editor behavior
vim.schedule(function() -- Schedule after 'UiEnter' for faster startup
  vim.opt.clipboard = "unnamedplus"
end)
opt.mouse = "a"
opt.splitright = true
opt.splitbelow = true

-- Numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Searching
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Performance & UI
opt.termguicolors = true
opt.scrolloff = 8
opt.wrap = false
opt.signcolumn = "yes"
opt.cursorline = true

opt.updatetime = 250
opt.timeoutlen = 350 -- Time to wait for completion of a keymap

-- Backup and Swap files
opt.backup = false
opt.swapfile = false
opt.writebackup = false
opt.undofile = true

-- Disable health checks for these providers.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
