vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" }, -- LSP config files
  { src = "https://github.com/mason-org/mason.nvim" }, -- LSP and other tool installer
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" }, -- Automatic LSP enable
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" }, -- Automatic installation of LSP's and other tools
})

local utils = require("utils")

local language_servers = {
  { name = "gopls", checker = "go" },
  { name = "ruff", checker = "python3" },
  { name = "ty", checker = "python3" },
  { name = "tinymist", checker = "typst" },
}

local ensure_installed = {
  "stylua",
  "lua_ls",
}

for _, lang in ipairs(language_servers) do
  if utils.has(lang.checker) then
    table.insert(ensure_installed, lang.name)
  end
end

require("mason").setup()
require("mason-lspconfig").setup({})
require("mason-tool-installer").setup({
  ensure_installed = ensure_installed,
  auto_update = false,
  run_on_start = true,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {
          "vim",
          "require",
        },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.config("ruff", {
  init_options = {
    settings = {
      lineLength = 120,
      organizeImports = true,
      exclude = {
        ".bzr",
        ".direnv",
        ".eggs",
        ".git",
        ".git-rewrite",
        ".hg",
        ".ipynb_checkpoints",
        ".mypy_cache",
        ".nox",
        ".pants.d",
        ".pyenv",
        ".pytest_cache",
        ".pytype",
        ".ruff_cache",
        ".svn",
        ".tox",
        ".venv",
        ".vscode",
        "__pypackages__",
        "_build",
        "buck-out",
        "build",
        "dist",
        "node_modules",
        "site-packages",
        "venv",
        "__init__.py",
        "__pycache__",
      },
      lint = {
        select = { "ALL" },
        -- https://docs.astral.sh/ruff/formatter/#conflicting-lint-rules
        ignore = {
          -- Modules
          "EXE",

          -- Specific rules
          "D100",
          "D101",
          "D102",
          "D103",
          "D104",
          "D105",
          "D106",
          "D107",
          "D200",
          "D205",
          "D206",
          "D212",
          "D300",
          "D400",
          "D401",
          "D415",

          "W191",

          "E111",
          "E114",
          "E117",
          "E402",
          "E501",

          "Q000",
          "Q001",
          "Q002",
          "Q003",

          "COM812",
          "COM819",

          "ISC002",
        },
      },
    },
  },
})

vim.lsp.config("ty", {
  settings = {
    ty = {
      diagnosticMode = "workspace",
    },
  },
})

-- LspAttach keymaps
vim.api.nvim_create_autocmd(
  "LspAttach",
  { --  Use LspAttach autocommand to only map the following keys after the language server attaches to the current buffer
    group = vim.api.nvim_create_augroup("RobinLspConfig", {}),
    callback = function(args)
      -- Set keymaps
      local opts = { buffer = args.buf }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "<leader>d", function()
        vim.diagnostic.open_float({
          border = "rounded",
        })
      end, opts)

      -- local client = vim.lsp.get_client_by_id(args.data.client_id)
      -- if client == nil then
      --   return
      -- end
    end,
  }
)
