-- CLI +commands run before VimEnter. Schedule tests after full startup so
-- asynchronous tools and plugin hooks see the same lifecycle as normal use.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      local ok, err = pcall(dofile, assert(vim.env.MODERN_TEST_SCRIPT))
      if not ok then
        io.stderr:write(tostring(err) .. "\n")
        vim.cmd("cquit")
      end
      vim.cmd("qa!")
    end)
  end,
})
