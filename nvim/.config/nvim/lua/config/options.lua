local opt = vim.opt

-- ═══════════════════════════════════════════════════════════════════════════════
-- Editor Behavior
-- ═══════════════════════════════════════════════════════════════════════════════

-- Use system clipboard for yank/paste (scheduled after UiEnter for faster startup)
vim.schedule(function()
  opt.clipboard = "unnamedplus"
end)

-- Enable mouse support in all modes
opt.mouse = "a"

-- New vertical splits go to the right
opt.splitright = true

-- New horizontal splits go to the bottom
opt.splitbelow = true

-- Allow unsaved buffers in the background
opt.hidden = true

-- Ask to save when quitting with unsaved changes (instead of error)
opt.confirm = true

-- ═══════════════════════════════════════════════════════════════════════════════
-- Line Numbers
-- ═══════════════════════════════════════════════════════════════════════════════

-- Show absolute line number on current line
opt.number = true

-- Show relative line numbers (great for motions like 5j)
opt.relativenumber = true

-- ═══════════════════════════════════════════════════════════════════════════════
-- Indentation
-- ═══════════════════════════════════════════════════════════════════════════════

-- Visual width of a tab character
opt.tabstop = 4

-- Number of spaces for autoindent
opt.shiftwidth = 4

-- Number of spaces Tab key inserts in insert mode
opt.softtabstop = 4

-- Use spaces instead of actual tabs
opt.expandtab = true

-- Copy indent from current line
opt.autoindent = true

-- Smart autoindenting when starting a new line
opt.smartindent = true

-- ═══════════════════════════════════════════════════════════════════════════════
-- Searching
-- ═══════════════════════════════════════════════════════════════════════════════

-- Highlight all search matches
opt.hlsearch = true

-- Show search results as you type
opt.incsearch = true

-- Case-insensitive search by default
opt.ignorecase = true

-- Case-sensitive if search pattern has uppercase
opt.smartcase = true

-- ═══════════════════════════════════════════════════════════════════════════════
-- Performance & UI
-- ═══════════════════════════════════════════════════════════════════════════════

-- Enable 24-bit RGB colors (required for modern themes)
opt.termguicolors = true

-- Keep 8 lines visible above/below cursor
opt.scrolloff = 8

-- Disable line wrapping (horizontal scroll instead)
opt.wrap = false

-- Always show sign column (prevents text jumping)
opt.signcolumn = "yes"

-- Highlight the current line
opt.cursorline = true

-- Rounded borders for floating windows (e.g., LSP popups)
opt.winborder = "rounded"

-- Faster completion and cursor hold events (ms)
opt.updatetime = 250

-- Time to wait for keymap sequence to complete (ms)
opt.timeoutlen = 350

-- Limit completion menu to 10 items
opt.pumheight = 10

-- Stop syntax highlighting after column 300 (performance)
opt.synmaxcol = 300

-- Cleaner UI characters for folds, diffs, etc.
opt.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  diff = "╱",
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- Whitespace Visualization
-- ═══════════════════════════════════════════════════════════════════════════════

-- Show special characters for certain whitespace
opt.list = true

opt.listchars = {
  -- Non-breaking space
  nbsp = "␣",
  -- Trailing space
  trail = "⋅",
  -- Tab character
  tab = "  ↦",
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- Backup & Persistence
-- ═══════════════════════════════════════════════════════════════════════════════

-- Don't create backup files
opt.backup = false

-- Don't create swap files (use undofile instead)
opt.swapfile = false

-- Don't make backup before overwriting
opt.writebackup = false

-- Persistent undo history across sessions
opt.undofile = true
