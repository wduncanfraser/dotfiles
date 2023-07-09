local M = {
  "folke/trouble.nvim",
}

function M.config()
  require("trouble").setup {
    icons = false,
    use_diagnostic_signs = true,
  }

  vim.keymap.set("n", "<leader>tt", "<cmd>TroubleToggle<cr>",
    { silent = true, noremap = true }
  )
  vim.keymap.set("n", "<leader>tw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
    { silent = true, noremap = true }
  )
  vim.keymap.set("n", "<leader>td", "<cmd>TroubleToggle document_diagnostics<cr>",
    { silent = true, noremap = true }
  )
  vim.keymap.set("n", "<leader>tr", "<cmd>TroubleToggle lsp_references<cr>",
    { silent = true, noremap = true }
  )
end

return M
