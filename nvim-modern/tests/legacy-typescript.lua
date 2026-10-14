vim.cmd.edit(vim.fn.fnameescape(assert(vim.env.MODERN_LEGACY_FIXTURE) .. "/sample.ts"))
local buf = vim.api.nvim_get_current_buf()
assert(
  vim.wait(90000, function()
    return #vim.lsp.get_clients({ bufnr = buf, name = "ts_ls" }) == 1
      and #vim.diagnostic.get(buf) > 0
  end, 100),
  "Mason's TypeScript fallback did not attach/report diagnostics"
)
assert(
  #vim.lsp.get_clients({ bufnr = buf, name = "tsc" }) == 0,
  "Native server must not attach to TS5"
)
local client = vim.lsp.get_clients({ bufnr = buf, name = "ts_ls" })[1]
assert(
  client.config.init_options.tsserver.path:find(
    "/classic/node_modules/typescript/lib/tsserver.js",
    1,
    true
  ),
  "Fallback ignored project-local TypeScript SDK"
)
assert(
  vim.iter(vim.diagnostic.get(buf)):any(function(d)
    return tonumber(d.code) == 2322
  end),
  "Missing expected TypeScript type error"
)
print("Legacy TypeScript integration passed: local SDK, managed server, no duplicate native server")
