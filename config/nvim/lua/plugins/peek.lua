local M = {
  'toppair/peek.nvim',
  event = { "VeryLazy" },
  build = 'deno task --quiet build:fast',
  keys = {
    {
      "<leader>pm",
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
  require("peek").setup({
    app = 'browser',
  })
  vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
  vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
end

return M
