return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v2.x',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
    { 'MunifTanjim/nui.nvim' },
  },
  config = function()
    -- Disable v1 keybinds
    vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

    -- Diagnostis
    -- vim.fn.sign_define("DiagnosticSignError",
    --   { text = " ", texthl = "DiagnosticSignError" })
    -- vim.fn.sign_define("DiagnosticSignWarn",
    --   { text = " ", texthl = "DiagnosticSignWarn" })
    -- vim.fn.sign_define("DiagnosticSignInfo",
    --   { text = " ", texthl = "DiagnosticSignInfo" })
    -- vim.fn.sign_define("DiagnosticSignHint",
    --   { text = "", texthl = "DiagnosticSignHint" })
    require("neo-tree").setup({
      default_component_configs = {
        icon = {
          folder_empty = "󰜌",
          folder_empty_open = "󰜌",
        },
        git_status = {
          symbols = {
            renamed  = "󰁕",
            unstaged = "󰄱",
          },
        },
      },
      filesystem = {
        hijack_netrw_behavior = "disabled"
      },
      window = {
        mappings = {
          ["<space>"] = "none",
        },
      },
    })

    vim.keymap.set('n', '<leader>e', '<Cmd>Neotree toggle<CR>')
  end
}
