local M = {
  'eandrju/cellular-automaton.nvim'
}

function M.config()
  vim.keymap.set("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>")
end

return M
