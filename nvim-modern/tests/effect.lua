-- MODERN_EFFECT_FIXTURES points to two independently configured temp projects.
local fixtures = assert(vim.env.MODERN_EFFECT_FIXTURES)
local function effect_diagnostics(buf)
  local out = {}
  for _, diagnostic in ipairs(vim.diagnostic.get(buf)) do
    if
      diagnostic.message:lower():match("yield") or diagnostic.message:lower():match("floating")
    then
      out[#out + 1] = diagnostic
    end
  end
  return out
end
for _, name in ipairs({ "effect-lsp", "effect-oxlint" }) do
  vim.cmd.edit(vim.fn.fnameescape(fixtures .. "/" .. name .. "/sample.ts"))
  local buf = vim.api.nvim_get_current_buf()
  assert(
    vim.wait(30000, function()
      return #effect_diagnostics(buf) > 0
    end, 50),
    name .. ": missing real Effect diagnostic"
  )
  local clients = vim.lsp.get_clients({ bufnr = buf })
  local native, legacy, oxlint = 0, 0, 0
  for _, client in ipairs(clients) do
    if client.name == "tsc" then
      native = native + 1
    end
    if client.name == "ts_ls" then
      legacy = legacy + 1
    end
    if client.name == "oxlint" then
      oxlint = oxlint + 1
    end
  end
  assert(native == 1 and legacy == 0, "Duplicate/wrong TypeScript servers in " .. name)
  if name == "effect-oxlint" then
    assert(oxlint == 1, "Local Oxlint not attached")
    assert(#effect_diagnostics(buf) == 1, "Effect diagnostic duplicated between LSP and Oxlint")
  end
  for _, diagnostic in ipairs(effect_diagnostics(buf)) do
    print(("%s: [%s] %s"):format(name, diagnostic.source or "LSP", diagnostic.message))
  end
end
print("Effect integration passed: native LSP, type-aware Oxlint, no duplicate Effect diagnostics")
