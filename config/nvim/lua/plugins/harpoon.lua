local M = {
  'theprimeagen/harpoon',
  dependencies = { 'nvim-lua/plenary.nvim' },
}

function M.config()
  require('harpoon').setup({
    global_settings = {
      tabline = true,
    },
  })

  local mark = require('harpoon.mark')
  local ui = require('harpoon.ui')

  local function toggle_move()
    if (vim.v.count > 0) then
      return '<cmd>lua require("harpoon.ui").nav_file(vim.v.count) <CR>'
    else
      mark.toggle_file()
    end
  end

  vim.keymap.set("n", "<leader>h", toggle_move, { expr = true })
  vim.keymap.set("n", "<leader>H", ui.toggle_quick_menu)
  vim.keymap.set("n", "]h", ui.nav_next)
  vim.keymap.set("n", "[h", ui.nav_prev)
end

return M
