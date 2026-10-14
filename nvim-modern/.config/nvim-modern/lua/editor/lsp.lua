local guide = require("editor.guide")
local ts = require("editor.typescript")
require("mason").setup()
require("mason-lspconfig").setup({ automatic_enable = false })
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
      telemetry = { enable = false },
    },
  },
})

local selected = {}
vim.lsp.config("tsc", {
  root_dir = function(buf, on_dir)
    local choice = ts.resolve(buf)
    if choice.mode == "tsc" then
      selected[choice.root] = choice
      on_dir(choice.root)
    end
  end,
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start(assert(selected[config.root_dir]).cmd, dispatchers)
  end,
})
vim.lsp.config("ts_ls", {
  root_dir = function(buf, on_dir)
    local choice = ts.resolve(buf)
    if choice.mode == "ts_ls" then
      selected[choice.root] = choice
      on_dir(choice.root)
    end
  end,
  before_init = function(params, config)
    local choice = selected[config.root_dir]
    if choice and choice.tsserver then
      params.initializationOptions = vim.tbl_deep_extend(
        "force",
        params.initializationOptions or {},
        { tsserver = { path = choice.tsserver } }
      )
      config.init_options = params.initializationOptions
    end
  end,
})

-- Use local Oxlint only when the project opts into it; never lint every TS
-- project with an editor-owned ruleset.
vim.lsp.config("oxlint", {
  root_dir = function(buf, on_dir)
    local root = vim.fs.root(buf, { { ".oxlintrc.json", ".oxlintrc.jsonc", "oxlint.config.ts" } })
    if root and ts.local_bin(buf, "oxlint") then
      on_dir(root)
    end
  end,
  cmd = function(dispatchers, config)
    local bin = assert(ts.local_bin(config.root_dir .. "/file.ts", "oxlint"))
    return vim.lsp.rpc.start({ bin, "--lsp" }, dispatchers)
  end,
  before_init = function(params, config)
    -- Project presets retain control of rules. Native type-aware companion is
    -- required; do not try to install/patch it from the editor.
    local companion = ts.local_bin(config.root_dir .. "/file.ts", "tsgolint")
    params.initializationOptions = vim.tbl_deep_extend(
      "force",
      params.initializationOptions or {},
      { settings = { typeAware = companion ~= nil } }
    )
  end,
})

local servers = {
  lua = { "lua_ls" },
  python = { "basedpyright" },
  rust = { "rust_analyzer" },
  go = { "gopls" },
  sh = { "bashls" },
  bash = { "bashls" },
  json = { "jsonls" },
  jsonc = { "jsonls" },
  yaml = { "yamlls" },
  html = { "html" },
  css = { "cssls" },
  c = { "clangd" },
  cpp = { "clangd" },
  typescript = { "ts_ls" },
  typescriptreact = { "ts_ls" },
  javascript = { "ts_ls" },
  javascriptreact = { "ts_ls" },
}
local pending = {}
local function ensure_server(name)
  if pending[name] then
    return
  end
  pending[name] = true
  require("mason-registry").refresh(function()
    vim.schedule(function()
      local registry = require("mason-registry")
      -- On a fresh app the map is empty UNTIL the registry has refreshed.
      local mappings = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
      local package_name = mappings[name]
      if not package_name or not registry.has_package(package_name) then
        pending[name] = nil
        vim.notify(
          "Mason has no package for " .. name .. ". See :MasonUpdate.",
          vim.log.levels.WARN
        )
        return
      end
      local package = registry.get_package(package_name)
      if package:is_installed() then
        pending[name] = nil
        vim.lsp.enable(name)
        return
      end
      package:once(
        "install:success",
        vim.schedule_wrap(function()
          pending[name] = nil
          -- Re-enable after installation to activate existing matching buffers.
          vim.lsp.enable(name, false)
          vim.lsp.enable(name)
        end)
      )
      package:once(
        "install:failed",
        vim.schedule_wrap(function()
          pending[name] = nil
          vim.notify(
            "Could not install " .. name .. ". See :Mason and :EditorHealth.",
            vim.log.levels.WARN
          )
        end)
      )
      if not package:is_installing() then
        vim.notify("Installing " .. name .. " for nvim-modern; see :Mason.")
        package:install()
      end
    end)
  end)
end
vim.lsp.enable({ "tsc", "oxlint" })
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    for _, name in ipairs(servers[vim.bo[ev.buf].filetype] or {}) do
      if name ~= "ts_ls" or ts.resolve(ev.buf).mode == "ts_ls" then
        ensure_server(name)
      end
    end
  end,
})

local function supports(method)
  return function()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if client:supports_method(method, 0) then
        return true
      end
    end
    return false, "No attached language server supports this here. See :EditorHealth / :Mason."
  end
end
local function action(id, key, title, method, help, run, remind, mode)
  guide.add({
    id = id,
    key = key,
    title = title,
    help = help,
    run = run,
    available = supports(method),
    remind = remind,
    mode = mode,
  })
end
action(
  "hover",
  "K",
  "Hover documentation",
  "textDocument/hover",
  "Types and documentation for the symbol under the cursor.",
  vim.lsp.buf.hover
)
action(
  "definition",
  "gd",
  "Go to definition",
  "textDocument/definition",
  "Jump to the definition; C-o returns.",
  vim.lsp.buf.definition
)
action(
  "references",
  "grr",
  "Find references",
  "textDocument/references",
  "Find uses of this symbol.",
  vim.lsp.buf.references
)
action(
  "rename",
  "grn",
  "Rename symbol",
  "textDocument/rename",
  "Semantic rename across the project.",
  vim.lsp.buf.rename
)
action(
  "code-actions",
  "gra",
  "Code actions here",
  "textDocument/codeAction",
  "Ask attached servers for actual fixes/refactors at the cursor or selection.",
  vim.lsp.buf.code_action,
  true,
  { "n", "x" }
)
action(
  "source-actions",
  "<leader>cs",
  "Whole-file code actions",
  "textDocument/codeAction",
  "Discover source actions such as organize imports and fix-all; varies by server.",
  function()
    local kinds = {}
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      local provider = client.server_capabilities.codeActionProvider
      for _, kind in ipairs(type(provider) == "table" and provider.codeActionKinds or {}) do
        if kind:match("^source") and not vim.tbl_contains(kinds, kind) then
          kinds[#kinds + 1] = kind
        end
      end
    end
    vim.lsp.buf.code_action({
      context = { only = #kinds > 0 and kinds or { "source" }, diagnostics = {} },
    })
  end,
  true
)
action(
  "implementation",
  "gri",
  "Go to implementation",
  "textDocument/implementation",
  "Find implementations of an interface.",
  vim.lsp.buf.implementation,
  true
)
action(
  "type-definition",
  "grt",
  "Go to type definition",
  "textDocument/typeDefinition",
  "Jump to the definition of a value's type.",
  vim.lsp.buf.type_definition
)
action(
  "symbols",
  "gO",
  "Document outline",
  "textDocument/documentSymbol",
  "Navigate symbols in this file.",
  vim.lsp.buf.document_symbol,
  true
)
action(
  "signature",
  "<leader>ck",
  "Signature help",
  "textDocument/signatureHelp",
  "Show parameters for the current call; also C-s in insert mode.",
  vim.lsp.buf.signature_help
)
action(
  "inlay-hints",
  "<leader>ci",
  "Toggle inlay hints",
  "textDocument/inlayHint",
  "Optional inferred type/parameter labels, off until you enable them.",
  function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
  end,
  true
)
action(
  "code-lens",
  "grx",
  "Run code lens",
  "textDocument/codeLens",
  "Server-provided actions such as references or tests.",
  function()
    vim.lsp.codelens.refresh()
    vim.lsp.codelens.run()
  end,
  true
)
guide.add({
  id = "ts-tooling",
  key = "<leader>ct",
  title = "Explain TypeScript / Effect tooling",
  help = "Show the selected compiler and how to enable Effect diagnostics without duplicate reports.",
  available = function()
    return ts.is_typescript(), "Open a JavaScript/TypeScript buffer first."
  end,
  run = ts.explain,
})
guide.add({
  id = "diagnostic-detail",
  key = "<leader>cd",
  title = "Diagnostic details",
  help = "Read full messages, including which server produced them.",
  run = vim.diagnostic.open_float,
})
guide.add({
  id = "diagnostic-list",
  key = "<leader>cq",
  title = "Project diagnostic list",
  help = "Collect diagnostics from loaded buffers into quickfix.",
  run = vim.diagnostic.setqflist,
})
