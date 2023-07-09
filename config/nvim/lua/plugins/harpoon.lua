local M = {
  'theprimeagen/harpoon',
  dependencies = { 'nvim-lua/plenary.nvim' },
}

function M.config()
  require('harpoon').setup({
    global_settings = {
      tabline = false,
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

  vim.keymap.set("n", "<leader>a", toggle_move, { expr = true })
  vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu)
  vim.keymap.set("n", "]h", ui.nav_next)
  vim.keymap.set("n", "[h", ui.nav_prev)
  vim.keymap.set("n", "<leader>fh", "<cmd>Telescope harpoon marks<cr>")
  vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end)
  vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end)
  vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end)
  vim.keymap.set("n", "<leader>4", function() ui.nav_file(4) end)
  vim.keymap.set("n", "<leader>5", function() ui.nav_file(5) end)
  vim.keymap.set("n", "<leader>6", function() ui.nav_file(6) end)
  vim.keymap.set("n", "<leader>7", function() ui.nav_file(7) end)
  vim.keymap.set("n", "<leader>8", function() ui.nav_file(8) end)
  vim.keymap.set("n", "<leader>9", function() ui.nav_file(9) end)
  vim.keymap.set("n", "<leader>0", function() ui.nav_file(0) end)
end

return M
