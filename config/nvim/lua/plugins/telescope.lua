local M = {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {
    defaults = {
      borderchars = {
        prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
        results = { "_" },
        preview = { " " },
      },
    }
  }
}

function M.config()
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>F', builtin.resume, {})
  vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
  vim.keymap.set('n', '<leader>fa', '<cmd>Telescope find_files follow=true no_ignore=true hidden=true <CR>', {})
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
end

return M
