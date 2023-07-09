return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'WhoIsSethDaniel/lualine-lsp-progress.nvim' },
  opts = {
    options = {
      icons_enabled = false,
      theme = 'gruvbox-baby',
    },
    sections = {
      lualine_b = { 'FugitiveHead', 'diff', 'diagnostics'},
      lualine_c = { 'filename', 'lsp_progress' }
    }
  },
}
