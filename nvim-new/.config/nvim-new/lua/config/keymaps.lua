local map = vim.keymap.set

-- Better map for returning from insert mode
map("i", "jk", "<Esc>", { noremap = true })

-- Map for seach highlight clear
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- Disable arrow keys
map("n", "<left>", '<Cmd>echo "Use h to move!!"<CR>')
map("n", "<right>", '<Cmd>echo "Use l to move!!"<CR>')
map("n", "<up>", '<Cmd>echo "Use k to move!!"<CR>')
map("n", "<down>", '<Cmd>echo "Use j to move!!"<CR>')
