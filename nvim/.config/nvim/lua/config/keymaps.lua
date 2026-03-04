local map = vim.keymap.set

-- Better escape from insert mode
map("i", "jk", "<Esc>", { noremap = true })

-- Clear search highlighting with Escape
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- Disable arrow keys (force hjkl usage)
map("n", "<left>", '<Cmd>echo "Use h to move!!"<CR>')
map("n", "<right>", '<Cmd>echo "Use l to move!!"<CR>')
map("n", "<up>", '<Cmd>echo "Use k to move!!"<CR>')
map("n", "<down>", '<Cmd>echo "Use j to move!!"<CR>')

-- Move lines up/down in normal mode
map("n", "<A-j>", "<Cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<Cmd>m .-2<CR>==", { desc = "Move line up" })

-- Move selected lines up/down in visual mode
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when jumping through search results
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
