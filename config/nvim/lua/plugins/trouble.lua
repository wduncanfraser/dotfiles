local M = {
  "folke/trouble.nvim",
}

function M.config()
  require("trouble").setup {
    icons = false,
    use_diagnostic_signs = true,
  }

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'Trouble: ' .. desc
    end

    vim.keymap.set('n', keys, func, { silent = true, noremap = true, desc = desc })
  end

  nmap('<leader>xx', require('trouble').toggle, 'Trouble Toggle')
  nmap('<leader>xw', function() require('trouble').open('workspace_diagnostics') end, 'Workspace Diagnostics')
  nmap('<leader>xd', function() require('trouble').open('document_diagnostics') end, 'Document Diagnostics')
  nmap('<leader>xq', function() require('trouble').open('quickfix') end, 'Quickfix List')
  nmap('<leader>xr', function() require('trouble').open('lsp_references') end, 'LSP References')
end

return M
