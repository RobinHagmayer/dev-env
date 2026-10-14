-- Choose ONE TypeScript server per project. Never patch/install project code.
local M = {}
local versions = {}
local locks = { "pnpm-lock.yaml", "package-lock.json", "yarn.lock", "bun.lock", "bun.lockb" }

function M.ancestors(source)
  local filename = type(source) == "number" and vim.api.nvim_buf_get_name(source) or source
  local dir = filename and filename ~= "" and vim.fs.dirname(vim.fs.abspath(filename))
    or vim.fn.getcwd()
  local dirs = {}
  while dir do
    dirs[#dirs + 1] = dir
    if vim.uv.fs_stat(dir .. "/.git") then
      break
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end
  return dirs
end

function M.local_bin(source, name)
  for _, dir in ipairs(M.ancestors(source)) do
    local bin = dir .. "/node_modules/.bin/" .. name
    if vim.fn.executable(bin) == 1 then
      return bin, dir
    end
  end
end

local function native(bin)
  if vim.fn.executable(bin) ~= 1 then
    return false
  end
  local stat = vim.uv.fs_stat(bin)
  if not stat then
    return false
  end
  local key = bin .. ":" .. stat.size .. ":" .. stat.mtime.sec .. ":" .. stat.mtime.nsec
  if versions[key] == nil then
    local ok, result = pcall(function()
      return vim.system({ bin, "--version" }, { text = true, timeout = 2000 }):wait()
    end)
    local version = ok and vim.version.parse(result.stdout or "")
    versions[key] = ok and result.code == 0 and version ~= nil and version.major >= 7
  end
  return versions[key]
end

function M.resolve(source)
  local dirs = M.ancestors(source)
  local root
  local package_root
  for _, dir in ipairs(dirs) do
    local found = false
    for _, lock in ipairs(locks) do
      if vim.uv.fs_stat(dir .. "/" .. lock) then
        root, found = dir, true
        break
      end
    end
    if found then
      break
    end
    if not package_root and vim.uv.fs_stat(dir .. "/package.json") then
      package_root = dir
    end
  end
  root = root or package_root or vim.fs.root(source, ".git") or dirs[1]
  local result = { mode = "ts_ls", root = root, effect = false }
  for _, dir in ipairs(dirs) do
    result.effect = result.effect
      or vim.uv.fs_stat(dir .. "/node_modules/@effect/tsgo/package.json") ~= nil
  end
  for _, dir in ipairs(dirs) do
    -- Test every local native candidate BEFORE considering any managed fallback.
    for _, name in ipairs({ "tsc", "tsgo" }) do
      local bin = dir .. "/node_modules/.bin/" .. name
      if native(bin) then
        result.mode, result.cmd = "tsc", { bin, "--lsp", "--stdio" }
        return result
      end
    end
    local tsserver = dir .. "/node_modules/typescript/lib/tsserver.js"
    if not result.tsserver and vim.uv.fs_stat(tsserver) then
      result.tsserver = tsserver
    end
  end
  return result
end

function M.is_typescript(buf)
  return vim.tbl_contains(
    { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    vim.bo[buf or 0].filetype
  )
end

function M.explain()
  local selected = M.resolve(0)
  local lines = {
    "TypeScript server: " .. selected.mode,
    "Project root: " .. selected.root,
    "Compiler: "
      .. (
        selected.cmd and selected.cmd[1]
        or selected.tsserver
        or "Mason-managed TypeScript fallback"
      ),
    "Project files are never patched by this editor.",
  }
  if selected.effect then
    lines[#lines + 1] =
      "Effect tooling found. Diagnostics require its patch and tsconfig plugin; package presence alone is not proof."
  else
    lines[#lines + 1] = "For Effect v4: install/configure @effect/tsgo using its project setup CLI."
  end
  lines[#lines + 1] =
    "With type-aware Oxlint Effect rules, set the tsconfig plugin's diagnostics=false to avoid duplicates."
  lines[#lines + 1] = "See the README's TypeScript/Effect section and :checkhealth vim.lsp."
  vim.lsp.util.open_floating_preview(lines, "markdown", { focus = true })
end
return M
