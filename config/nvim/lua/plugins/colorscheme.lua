return { 
  {
    'luisiacc/gruvbox-baby', 
    branch = 'main',
    config = function()
      -- Dark background
      vim.g.gruvbox_baby_background_color = 'dark'
      -- Enable telescope theme
      vim.g.gruvbox_baby_telescope_theme = 1
      -- Load colorscheme
      vim.cmd([[colorscheme gruvbox-baby]])
    end,
  }
}
