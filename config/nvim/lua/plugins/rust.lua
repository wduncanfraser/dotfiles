return {
  {
    "Saecki/crates.nvim",
    event = 'BufRead Cargo.toml',
    tag = 'stable',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
    config = function()
      require("crates").setup()
    end,
  },
}
