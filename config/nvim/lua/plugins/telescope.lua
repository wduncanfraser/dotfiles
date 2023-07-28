local M = {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.2',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
  },
  opts = {
    defaults = {
      borderchars = {
        prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
        results = { "_" },
        preview = { " " },
      },
    }
  },
}

function M.config()
  local builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>f<leader>', builtin.resume, {})
  vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
  vim.keymap.set('n', '<leader>fa', '<cmd>Telescope find_files follow=true no_ignore=true hidden=true <CR>', {})
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
  vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
  vim.keymap.set('n', '<leader>fH', builtin.help_tags, {})
  vim.keymap.set('n', '<leader>/', function()
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })
end

return M
