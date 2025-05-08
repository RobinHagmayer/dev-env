local map = vim.keymap.set

map("i", "jk", "<Esc>", { noremap = true })

map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- Disable arrow keys.
vim.keymap.set("n", "<left>", '<Cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<Cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<Cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<Cmd>echo "Use j to move!!"<CR>')
