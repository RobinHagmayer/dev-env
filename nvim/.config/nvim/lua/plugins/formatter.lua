return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  ---@module "conform"
  ---@diagnostic disable-next-line: undefined-doc-name
  ---@type conform.setupOpts
  opts = {
    formatters_by_ft = {
      go = { "gofmt" },
      lua = { "stylua" },
      markdown = { "prettierd" },
      -- Webdev
      html = { "prettierd" },
      css = { "prettierd" },
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      astro = { "prettierd" },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
    format_on_save = { timeout_ms = 500 },
    -- Set log level
    -- log_level = vim.log.levels.DEBUG,
  },
}
