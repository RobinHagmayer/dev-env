local opt = vim.opt

-- Editor behavior
vim.schedule(function() -- Schedule after 'UiEnter' for faster startup
  -- Use system clipboard for yank/paste
  opt.clipboard = "unnamedplus"
end)
opt.mouse = "a" -- Enable mouse support in all modes
opt.splitright = true -- New vertical splits go to the right
opt.splitbelow = true -- New horizontal splits go to the bottom

-- Numbers
opt.number = true -- Show absolute line numbers
opt.relativenumber = true -- Show line numbers relative to the cursor

-- Indentation
opt.tabstop = 4 -- Number of spaces a <Tab> in the file counts for
opt.shiftwidth = 4 -- Number of spaces to use for each step of (auto)indent
opt.expandtab = true -- Use spaces instead of tabs
opt.autoindent = true -- Copy indent from current line when starting a new line
opt.smartindent = true -- Be smart about indentation

-- Searching
opt.hlsearch = true -- Highlight all matches on search
opt.incsearch = true -- Show search results as you type
opt.ignorecase = true -- Ignore case in search patterns
opt.smartcase = true -- Override 'ignorecase' if the search pattern has uppercase

-- Performance & UI
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.scrolloff = 8 -- Keep 8 lines of context around the cursor
opt.wrap = false -- Disable line wrapping
opt.signcolumn = "yes" -- Always show the sign column
opt.cursorline = true -- Highlight the current line
opt.winborder = "rounded" -- Use rounded borders for floating windows

opt.updatetime = 250 -- Faster completion (default is 4000ms)
opt.timeoutlen = 350 -- Time to wait for completion of a keymap

-- Show certain whitespace characters
opt.list = true -- Enable the display of characters in 'listchars'
opt.listchars = { nbsp = "␣", trail = "⋅", tab = "  ↦" } -- Characters to display

-- Backup and Swap files
opt.backup = false -- Do not create a backup file
opt.swapfile = false -- Do not create a swap file
opt.writebackup = false -- Do not make a backup before overwriting a file
opt.undofile = true -- Enable persistent undo
