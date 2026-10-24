-- Exercise the actual searchable palette and its return-to-buffer behavior.
local guide = require("editor.guide")
vim.cmd.enew()
local origin = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(origin, 0, -1, false, { "first", "second" })
local result
guide.add({
  id = "palette-test",
  title = "zztestpalette",
  help = "Integration test action",
  run = function()
    result = {
      buffer = vim.api.nvim_get_current_buf(),
      mode = vim.fn.mode(),
      anchor = vim.fn.getpos("v"),
      cursor = vim.fn.getpos("."),
    }
  end,
})
local function choose()
  vim.defer_fn(function()
    vim.api.nvim_input("zztestpalette")
    vim.defer_fn(function()
      vim.api.nvim_input("<CR>")
    end, 200)
  end, 100)
  guide.palette(false)
  assert(
    vim.wait(2000, function()
      return result ~= nil
    end, 10),
    "Palette did not execute action"
  )
  assert(result.buffer == origin, "Palette ran action in its own scratch buffer")
end
choose()
assert(result.mode == "n", "Palette did not restore normal mode")
result = nil
vim.api.nvim_win_set_cursor(0, { 1, 0 })
vim.cmd("normal! v")
vim.api.nvim_win_set_cursor(0, { 2, 3 })
choose()
assert(result.mode == "v", "Palette lost visual mode")
assert(
  result.anchor[2] == 1 and result.cursor[2] == 2 and result.cursor[3] == 4,
  "Palette changed the visual range"
)
vim.cmd("normal! " .. vim.keycode("<Esc>"))
vim.bo.modified = false
print("Palette integration passed: searchable actions, original buffer, visual selection preserved")
