local guide = require("editor.guide")
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    javascript = { "oxfmt", "prettier", stop_after_first = true },
    javascriptreact = { "oxfmt", "prettier", stop_after_first = true },
    typescript = { "oxfmt", "prettier", stop_after_first = true },
    typescriptreact = { "oxfmt", "prettier", stop_after_first = true },
    json = { "oxfmt", "prettier", stop_after_first = true },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    markdown = { "prettier" },
    rust = { "rustfmt" },
    go = { "gofmt" },
    sh = { "shfmt" },
  },
  -- Explicit formatting, no silent on-save rewrites.
  default_format_opts = { lsp_format = "fallback", timeout_ms = 3000 },
})
require("mason-tool-installer").setup({
  ensure_installed = { "stylua", "prettier", "shfmt", "ruff" },
  run_on_start = true,
  start_delay = 1000,
  auto_update = false,
})
guide.add({
  id = "format",
  key = "<leader>cf",
  mode = { "n", "x" },
  title = "Format buffer or selection",
  help = "Prefer project-local formatter; fall back to LSP. Formatting is explicit, not automatic on save.",
  available = function()
    local formatters, lsp = require("conform").list_formatters_to_run(0)
    return #formatters > 0 or lsp, "No formatter here yet. See :ConformInfo / :Mason."
  end,
  run = function()
    require("conform").format({ async = true })
  end,
})
