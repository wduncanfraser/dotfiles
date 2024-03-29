return {
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  },
  {
    'danymat/neogen',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = true,
    keys = {
      { "<leader>cc", function() require("neogen").generate({}) end, desc = "Neogen Comment" },
    }
  }
}
