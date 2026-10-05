local M = { active = false }
local guide = require("editor.guide")
local function root()
  return vim.fs.root(0, ".git") or vim.fs.root(0, "package.json") or vim.fn.getcwd()
end
function M.help()
  local lines = {
    "FFF: Enter opens; C-s split; C-v vertical split; Esc closes.",
    "C-n/C-p move; C-u/C-d scroll preview; Tab marks; C-q sends to quickfix.",
    "Shift-Tab switches grep mode (plain/regex). C-Up/C-Down recall queries.",
    "Scope queries: git:modified, git:staged, src/, *.ts, !test/",
    "Space f t outside the picker searches EXACT Git-tracked files.",
  }
  vim.lsp.util.open_floating_preview(lines, "markdown", { focus = true, border = "rounded" })
end
require("fff").setup({
  prompt = "> ",
  prompt_vim_mode = false,
  enable_home_dir_scanning = false,
  enable_fs_root_scanning = false,
  layout = { prompt_position = "top" },
  debug = { enabled = false, show_scores = false },
  grep = { modes = { "plain", "regex" } }, -- No surprise fuzzy content matches.
  select = {
    select_window = function()
      return nil
    end,
  },
  mappings = { i = { ["<F1>"] = M.help }, n = { ["<F1>"] = M.help } },
})
vim.api.nvim_create_autocmd("User", {
  pattern = { "FFFOpen", "FFFClose" },
  callback = function(ev)
    M.active = ev.match == "FFFOpen"
  end,
})
local function finder(method, opts)
  opts = opts or {}
  opts.cwd = root()
  require("fff")[method](opts)
end
guide.add({
  id = "files",
  key = "<leader>ff",
  title = "Find files",
  help = "Fast project file search; F1 inside the picker explains its controls.",
  run = function()
    finder("find_files")
  end,
})
guide.add({
  id = "grep",
  key = "<leader>fg",
  title = "Search text",
  help = "Literal project search; Shift-Tab switches to regex; F1 shows filters.",
  run = function()
    finder("live_grep")
  end,
})
guide.add({
  id = "grep-word",
  key = "<leader>fw",
  mode = { "n", "x" },
  title = "Search word or selection",
  remind = true,
  help = "Search the project for the word under the cursor or selected text.",
  run = function()
    finder("live_grep_under_cursor")
  end,
})
guide.add({
  id = "changed-files",
  key = "<leader>fm",
  title = "Find modified files",
  remind = true,
  help = "Open FFF with git:modified already filled in.",
  available = function()
    return vim.fs.root(0, ".git") ~= nil, "This buffer is not inside a Git repository."
  end,
  run = function()
    finder("find_files", { query = "git:modified " })
  end,
})
guide.add({
  id = "git-files",
  key = "<leader>ft",
  title = "Find Git-tracked files",
  help = "Exact Git index scope (not merely files that aren't ignored). Uses a small auxiliary picker.",
  available = function()
    return vim.fs.root(0, ".git") ~= nil, "This buffer is not inside a Git repository."
  end,
  run = function()
    local cwd = root()
    vim.system({ "git", "-C", cwd, "ls-files", "-z", "--cached" }, {}, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify(result.stderr, vim.log.levels.ERROR)
          return
        end
        local items = vim.split(result.stdout or "", "\0", { trimempty = true })
        require("mini.pick").start({
          source = { name = "Git-tracked files", cwd = cwd, items = items },
        })
      end)
    end)
  end,
})
guide.add({
  id = "fff-help",
  title = "FFF picker controls",
  help = "Filters, preview scrolling, multiselect, quickfix and grep modes.",
  run = M.help,
})
guide.add({
  id = "buffers",
  key = "<leader>fb",
  title = "Switch open buffers",
  help = "Search currently open buffers, not every file.",
  run = function()
    require("mini.pick").builtin.buffers()
  end,
})
guide.add({
  id = "commands",
  key = "<leader>hc",
  title = "Search Neovim commands",
  help = "Search built-in/plugin commands; select to run or enter required arguments.",
  run = function()
    require("mini.extra").pickers.commands()
  end,
})
return M
