vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" }, -- LSP config files
  { src = "https://github.com/mason-org/mason.nvim" }, -- LSP and other tool installer
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" }, -- Automatic LSP enable
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" }, -- Automatic installation of LSP's and other tools
})

require("mason").setup()
require("mason-lspconfig").setup({})
require("mason-tool-installer").setup({
  ensure_installed = {
    "stylua", -- Lua formatter
    "lua_ls", -- Lua language server
    "gopls", -- Go language server
    "python-lsp-server", -- Python language server
  },
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
