local M = {}

M.has = function(name)
  return vim.fn.executable(name) == 1
end

return M
