local guide = require("editor.guide")
require("mini.surround").setup()
guide.add({
  id = "surround",
  title = "Surround editing",
  remind = true,
  help = "sa adds, sd deletes, sr replaces surrounding quotes/brackets. Example: saiw followed by a quote.",
  run = function()
    vim.notify(
      "sa adds surroundings, sd deletes, sr replaces. Example: saiw followed by a quote. See :help MiniSurround."
    )
  end,
})
guide.add({
  id = "comments",
  title = "Comment code",
  help = "Native gcc comments a line; gc plus motion/visual selection comments a region.",
  run = function()
    vim.cmd("help gc")
  end,
})
guide.add({
  id = "folds",
  title = "Syntax folds",
  remind = true,
  help = "za toggles a fold, zM closes all, zR opens all. Files begin unfolded.",
  available = function()
    return vim.wo.foldmethod == "expr", "No syntax folds active in this window."
  end,
  run = function()
    vim.cmd("help fold-commands")
  end,
})
guide.add({
  id = "update-plugins",
  key = "<leader>up",
  title = "Update editor plugins",
  help = "Review vim.pack changes; :write accepts, :quit cancels. Restart after updating.",
  run = function()
    vim.pack.update()
  end,
})
guide.add({
  id = "update-tools",
  key = "<leader>ut",
  title = "Update managed editor tools",
  help = "Update Mason-installed servers/formatters, not project-local dependencies.",
  run = function()
    local registry = require("mason-registry")
    registry.refresh(function()
      vim.schedule(function()
        for _, package in ipairs(registry.get_installed_packages()) do
          if not package:is_installing() then
            package:install()
          end
        end
        vim.notify("Updating all installed Mason tools. See :Mason; restart after completion.")
      end)
    end)
  end,
})
guide.add({
  id = "update-parsers",
  key = "<leader>us",
  title = "Update syntax parsers",
  help = "Rebuild installed parsers for the current Tree-sitter plugin.",
  run = function()
    require("nvim-treesitter").update(nil, { summary = true })
  end,
})
guide.add({
  id = "health",
  key = "<leader>uh",
  title = "Editor health and missing tools",
  help = "Check environment, plugins, parsers and language-server selection.",
  run = function()
    vim.cmd("EditorHealth")
  end,
})
vim.keymap.set("n", "<A-j>", "<Cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<Cmd>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("x", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("x", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlighting" })
vim.keymap.set("n", "<leader>qq", "<cmd>copen<cr>", { desc = "Open quickfix list" })
