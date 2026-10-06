vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.winborder = "rounded"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus" -- Use the system clipboard for yank/paste.
vim.opt.confirm = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = math.max(0, math.floor(vim.o.lines / 2) - 3)
vim.opt.sidescrolloff = 6
vim.opt.updatetime = 700
vim.opt.timeoutlen = 500
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.breakindent = true
vim.opt.wrap = false
vim.opt.list = true
vim.opt.listchars = { nbsp = "␣", trail = "⋅", tab = "  ↦" }
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.laststatus = 3
vim.opt.exrc = false -- Never execute project-local Lua implicitly.
vim.opt.statusline = " %f %m%r %= %{v:lua.require'editor.guide'.status()} %l:%c "
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, source = "if_many" },
  float = { source = true },
  update_in_insert = false,
})
vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Disable automatic comment continuation and wrapping",
  callback = function()
    for _, flag in ipairs({ "c", "r", "o" }) do
      vim.opt_local.formatoptions:remove(flag)
    end
  end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})
