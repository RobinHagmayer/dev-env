-- Run with the full config, isolated XDG dirs, and installed test prerequisites.
local function check(condition, message)
  assert(condition, message)
end
local guide = require("editor.guide")
for _, name in ipairs({ "completion", "navigation", "treesitter", "lsp", "formatting", "editing" }) do
  check(package.loaded["editor." .. name] ~= nil, name .. " module failed to load")
end
check(#guide.actions >= 35, "Feature guide missing actions")
check(vim.fn.exists(":EditorFeatures") == 2, "Missing contextual palette")
check(vim.fn.exists(":EditorReminders") == 2, "Missing reminder controls")
check(vim.fn.stdpath("data"):match("nvim%-modern$"), "App data not isolated")
local fixture = assert(vim.env.MODERN_FIXTURE)
vim.cmd.edit(vim.fn.fnameescape(fixture .. "/sample.lua"))
check(
  vim.wait(60000, function()
    local parser = vim.treesitter.get_parser(0)
    return parser ~= nil
      and vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil
  end, 50),
  "Lua parser/highlighter did not become ready"
)
check(require("editor.treesitter").available("@function.outer"), "Function textobject missing")
check(
  vim.wait(60000, function()
    return #vim.lsp.get_clients({ bufnr = 0, name = "lua_ls" }) == 1
  end, 50),
  "Lua server was not installed/attached automatically"
)
local lsp_actions = guide.list(false)
check(
  vim.iter(lsp_actions):any(function(item)
    return item.action.id == "code-actions"
  end),
  "Attached LSP not reflected in guide"
)
check(
  vim.wait(60000, function()
    local info = require("conform").get_formatter_info("stylua", 0)
    return info.available
  end, 50),
  "StyLua did not become ready"
)
-- Operator-pending and normal-mode syntax actions must both work.
vim.api.nvim_win_set_cursor(0, { 3, 6 })
vim.cmd("normal vaf")
check(vim.fn.mode():match("^[vV]"), "Function textobject did not select")
vim.cmd("normal! " .. vim.keycode("<Esc>"))
vim.cmd("normal daf")
check(
  not table
    .concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
    :find("local function", 1, true),
  "Operator-pending function deletion failed"
)
vim.cmd.undo()
vim.api.nvim_win_set_cursor(0, { 1, 0 })
local format_error
require("conform").format({ async = false, timeout_ms = 5000 }, function(err)
  format_error = err
end)
check(not format_error, "Formatter failed: " .. tostring(format_error))
check(vim.api.nvim_get_current_line() ~= "local x={a=1,b=2}", "StyLua made no change")
vim.bo.modified = false
-- Open the real picker first: current FFF's programmatic wait helper assumes
-- the UI's file_picker.setup() has run.
require("fff").find_files({ cwd = fixture, query = "sample.lua" })
check(require("editor.navigation").active, "FFFOpen did not fire")
require("fff.picker_ui.picker_ui").close()
check(not require("editor.navigation").active, "FFFClose did not fire")
local found = require("fff").file_search("sample.lua", { cwd = fixture, wait_for_index_ms = 10000 })
check(found.total_matched > 0, "FFF native file search failed")
local matches = require("fff").content_search(
  "needle",
  { cwd = fixture, mode = "plain", wait_for_index_ms = 10000 }
)
check(matches.total_matched > 0, "FFF native content search failed")
guide.help()
check(
  vim.bo.buftype == "nofile" and vim.bo.modifiable == false,
  "Guide must be readonly scratch content"
)
vim.cmd.close()
vim.cmd("checkhealth editor")
check(
  not table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"):match("ERROR"),
  "Editor health reported an error"
)
print("Integration: parser, text objects, on-demand LSP, formatting, FFF search and guide passed")
