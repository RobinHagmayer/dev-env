local map = vim.keymap.set

-- Set leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Better map for returning from insert mode
map("i", "jk", "<Esc>", { noremap = true })

-- Map for seach highlight clear
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- Disable arrow keys.
vim.keymap.set("n", "<left>", '<Cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<Cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<Cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<Cmd>echo "Use j to move!!"<CR>')
