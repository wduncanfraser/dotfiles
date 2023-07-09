local M = {
  'luisiacc/gruvbox-baby',
  priority = 1000,
  branch = 'main',
}

function M.config()
  local c = require("gruvbox-baby.colors").config()
  -- Dark background
  vim.g.gruvbox_baby_background_color = 'dark'
  -- Color overrides
  vim.g.gruvbox_baby_highlights = {
    ColorColumn = { bg = c.comment }, -- can be any color you want
  }
  -- Enable telescope theme
  vim.g.gruvbox_baby_telescope_theme = 1
  -- Load colorscheme
  vim.cmd('colorscheme gruvbox-baby')
end

return M
