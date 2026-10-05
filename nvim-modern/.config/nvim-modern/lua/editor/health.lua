local M = {}
function M.check()
  vim.health.start("Modern editor")
  vim.health.info(
    "Neovim " .. tostring(vim.version()) .. "; app " .. (vim.env.NVIM_APPNAME or "nvim")
  )
  if vim.env.NVIM_APPNAME == "nvim-modern" then
    vim.health.ok("Independent config/data/state/cache")
  else
    vim.health.warn("Launch with NVIM_APPNAME=nvim-modern to protect your regular config.")
  end
  for _, tool in ipairs({ "git", "curl", "tar", "cc", "tree-sitter", "node", "npm", "rg" }) do
    if vim.fn.executable(tool) == 1 then
      vim.health.ok(tool .. ": " .. vim.fn.exepath(tool))
    else
      vim.health.warn("Missing " .. tool, { "See nvim-modern/README.md prerequisites." })
    end
  end
  if vim.fn.executable("tree-sitter") == 1 then
    local out = vim.system({ "tree-sitter", "--version" }, { text = true }):wait()
    local version = vim.version.parse(out.stdout or "")
    if version and vim.version.ge(version, { 0, 26, 1 }) then
      vim.health.ok("Tree-sitter CLI >= 0.26.1")
    else
      vim.health.error("Tree-sitter CLI needs 0.26.1+. Install with cargo, not npm.")
    end
  end
  vim.health.start("Current buffer")
  local buf = vim.g.editor_health_buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    buf = 0
  end
  local clients = vim.lsp.get_clients({ bufnr = buf })
  for _, client in ipairs(clients) do
    vim.health.ok("Attached LSP: " .. client.name)
  end
  if #clients == 0 then
    vim.health.info("No LSP attached. Open code, then :checkhealth vim.lsp / :Mason.")
  end
  local ts = require("editor.typescript")
  if ts.is_typescript(buf) then
    local selection = ts.resolve(buf)
    vim.health.info("Selected TypeScript server: " .. selection.mode .. " at " .. selection.root)
    if selection.effect then
      vim.health.info(
        "Effect package found; use Space c t for setup/duplicate-diagnostic guidance."
      )
    end
  end
  local parser = vim.treesitter.get_parser(buf)
  if parser then
    vim.health.ok("Syntax parser: " .. parser:lang())
  else
    vim.health.info(
      "No parser in this buffer. Parsers install on demand when the CLI is available."
    )
  end
  vim.health.info("For details: :checkhealth mason, :checkhealth fff, :ConformInfo")
end
return M
