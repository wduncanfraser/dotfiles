return {
  -- Lazydev
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Mason automatically installs LSPS and related tools
      {
        'mason-org/mason.nvim',
        opts = {},
      },
      'mason-org/mason-lspconfig.nvim',

      -- Status updates for LSP
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      'saghen/blink.cmp',
    },
    config = function()
      --  This function gets run when an LSP connects to a particular buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- See `:help K` for why this keymap
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
        end
      })

      -- blink.cmp supports additional completion capabilities
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      require('mason-lspconfig').setup {
        ensure_installed = {
          "lua_ls",
          "rust_analyzer",
          "svelte",
          "ts_ls",
        },
        handlers = {
          function(server_name) -- default handler
            require("lspconfig")[server_name].setup {
              capabilities = capabilities,
              on_attach = on_attach,
            }
          end,
          ["lua_ls"] = function()
            require('lspconfig').lua_ls.setup {
              capabilities = capabilities,
              on_attach = on_attach,
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { 'vim' }
                  },
                  workspace = {
                    checkThirdParty = false
                  },
                  telemetry = {
                    enable = false
                  },
                }
              }
            }
          end
        }
      }
    end
  }
}
