local M = {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.2',
  dependencies = {
    'nvim-telescope/telescope-file-browser.nvim',
    'nvim-lua/plenary.nvim'
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
  require("telescope").setup {
    extensions = {
      file_browser = {
        dir_icon = "",
        hijack_netrw = true,
      }
    }
  }

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

  require("telescope").load_extension "file_browser"
  local file_browser = require('telescope').extensions.file_browser
  vim.keymap.set('n', '<leader>fe', file_browser.file_browser, { noremap = true })
end

return M
