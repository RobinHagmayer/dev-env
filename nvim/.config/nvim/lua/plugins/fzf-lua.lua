return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<leader>fb", "<Cmd>FzfLua lgrep_curbuf<CR>", desc = "Grep current buffer" },
    { "<leader>fd", "<cmd>FzfLua lsp_document_diagnostics<cr>", desc = "Document diagnostics" },
    { "<leader>fD", "<cmd>FzfLua lsp_workspace_diagnostics<cr>", desc = "Workspace diagnostics" },
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Grep" },
    { "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help" },
    { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
  },
  opts = {
    -- Generate fzf's colorscheme from Neovims colorscheme
    fzf_colors = true,
  },
}
