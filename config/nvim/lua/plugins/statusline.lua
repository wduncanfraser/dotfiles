return {
  'nvim-lualine/lualine.nvim',
  opts = {
    options = {
      icons_enabled = true,
      theme = 'gruvbox-baby',
    },
    sections = {
      lualine_b = { 'FugitiveHead', 'diff', 'diagnostics' },
      lualine_c = { 'filename' }
    }
  },
}
