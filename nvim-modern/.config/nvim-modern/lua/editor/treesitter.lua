local M = {}
local guide = require("editor.guide")
local treesitter = require("nvim-treesitter")
treesitter.setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
local supported = {}
for _, lang in ipairs(treesitter.get_available()) do
  supported[lang] = true
end
local pending = {}

function M.available(capture)
  local parser = vim.treesitter.get_parser(0)
  if not parser then
    return false, "No syntax parser here yet. See :EditorHealth / :TSInstall."
  end
  if capture then
    local query = vim.treesitter.query.get(parser:lang(), "textobjects")
    if not query or not vim.tbl_contains(query.captures, (capture:gsub("^@", ""))) then
      return false, "This language does not provide the " .. capture .. " text object."
    end
  end
  return true
end
local function start(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  if pcall(vim.treesitter.start, buf) then
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      vim.wo[win].foldmethod = "expr"
      vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo[win].foldlevel = 99 -- Never hide code on opening a file.
    end
  end
end
vim.api.nvim_create_autocmd("FileType", {
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" or vim.api.nvim_buf_line_count(ev.buf) > 20000 then
      return
    end
    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
    if not lang then
      return
    end
    local parser = vim.treesitter.get_parser(ev.buf, lang)
    if parser then
      start(ev.buf)
      return
    end
    if not supported[lang] or pending[lang] then
      return
    end
    if vim.fn.executable("tree-sitter") ~= 1 then
      return
    end
    pending[lang] = true
    treesitter.install({ lang }):await(function(err)
      vim.schedule(function()
        pending[lang] = nil
        if err then
          vim.notify("Parser install: " .. tostring(err), vim.log.levels.WARN)
          return
        end
        -- Include other buffers opened while the installation was running.
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if
            vim.api.nvim_buf_is_loaded(buf)
            and vim.treesitter.language.get_lang(vim.bo[buf].filetype) == lang
          then
            start(buf)
          end
        end
      end)
    end)
  end,
})
require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },
  move = { set_jumps = true },
})
local function textobject(id, key, title, capture)
  guide.add({
    id = id,
    key = key,
    mode = { "x", "o" },
    title = title,
    help = "Combine with v/d/c/y: e.g. v" .. key .. " selects; c" .. key .. " changes.",
    available = function()
      return M.available(capture)
    end,
    run = function()
      if vim.fn.mode(1) == "n" then
        vim.cmd("normal! v")
      end
      require("nvim-treesitter-textobjects.select").select_textobject(capture, "textobjects")
    end,
  })
end
textobject("function-outer", "af", "Around function", "@function.outer")
textobject("function-inner", "if", "Inside function", "@function.inner")
textobject("argument-outer", "aa", "Around argument", "@parameter.outer")
textobject("argument-inner", "ia", "Inside argument", "@parameter.inner")
guide.add({
  id = "select-function",
  key = "<leader>tf",
  title = "Select function",
  remind = true,
  help = "Select a whole function structurally; also vaf/daf/cif.",
  available = function()
    return M.available("@function.outer")
  end,
  run = function()
    vim.cmd("normal! v")
    require("nvim-treesitter-textobjects.select").select_textobject(
      "@function.outer",
      "textobjects"
    )
  end,
})
guide.add({
  id = "grow-selection",
  key = "<leader>te",
  mode = { "n", "x" },
  title = "Expand syntax selection",
  remind = true,
  help = "Select the enclosing syntax node; repeat to grow. Native visual an grows / in shrinks.",
  available = M.available,
  run = function()
    vim.treesitter.select("parent")
  end,
})
for _, direction in ipairs({ "next", "previous" }) do
  local key = direction == "next" and "]m" or "[m"
  guide.add({
    id = direction .. "-function",
    key = key,
    title = "Jump to " .. direction .. " function",
    help = "Move by syntax, not text matching.",
    available = function()
      return M.available("@function.outer")
    end,
    run = function()
      require("nvim-treesitter-textobjects.move")["goto_" .. direction .. "_start"](
        "@function.outer",
        "textobjects"
      )
    end,
  })
  guide.add({
    id = direction .. "-argument",
    key = direction == "next" and "<leader>tn" or "<leader>tp",
    title = "Swap with " .. direction .. " argument",
    remind = true,
    help = "Reorder function arguments structurally.",
    available = function()
      return M.available("@parameter.inner")
    end,
    run = function()
      require("nvim-treesitter-textobjects.swap")["swap_" .. direction]("@parameter.inner")
    end,
  })
end
return M
