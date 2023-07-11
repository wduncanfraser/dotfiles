local M = {
  -- TODO: This should be 'toppair/peek.nvim'
  -- Fix for plugin not building
  'cloudsftp/peek.nvim',
  branch = 'bundle',
  build = 'deno task --quiet build:fast',
  keys = {
    {
      "<leader>op",
      function()
        local peek = require("peek")
        if peek.is_open() then
          peek.close()
        else
          peek.open()
        end
      end,
      desc = "Peek (Markdown Preview)",
    },
    opts = {
      syntax = false,
    }
  },
}

function M.config()
  require("peek").setup()
  vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
  vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
end

return M
