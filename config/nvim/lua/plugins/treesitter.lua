return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "fish",
        "html",
        "javascript",
        "json",
        "kotlin",
        "lua",
        "proto",
        "query",
        "rust",
        "sql",
        "terraform",
        "toml",
        "typescript",
        "vim",
        "vimdoc",
      },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = false },
    }
  },
  {
    "nvim-treesitter/playground"
  }
}
