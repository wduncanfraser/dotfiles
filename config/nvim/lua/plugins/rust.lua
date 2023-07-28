return {
  {
    "Saecki/crates.nvim",
    event = 'BufRead Cargo.toml',
    tag = 'v0.3.0',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
    config = function()
      require("crates").setup()
    end,
  },
}
