local M = {
  'tpope/vim-fugitive'
}

function M.config()
  vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { desc = 'Fugitive: [G]it [s]tatus' })
end

return M
