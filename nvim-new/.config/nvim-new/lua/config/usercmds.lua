vim.api.nvim_create_user_command("Redir", function(ctx)
  local result = vim.api.nvim_exec2(ctx.args, { output = true })
  local output = result.output or ""
  local lines = vim.split(output, "\n", { plain = true })

  vim.cmd("new")
  -- Set buffer options for a scratch buffer
  vim.opt_local.buftype = "nofile"
  vim.opt_local.buflisted = true
  vim.opt_local.bufhidden = "wipe"
  vim.opt_local.modified = false
  vim.opt_local.swapfile = false

  -- Set the buffer name (visible in statusline/tabline)
  vim.cmd("file [Redir Output: " .. ctx.args .. "]")
  -- Set the lines in the new buffer
  -- '0' for current buffer, '0' start line, '-1' end line (all existing), 'false' for do_not_detach
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd("normal! gg")
end, {
  nargs = "+",
  complete = "command",
  desc = "Redirects output of a Vim command to a new buffer",
})
