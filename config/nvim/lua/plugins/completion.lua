return {
  -- Autocompletion
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    opts = {
      keymap = { preset = 'default' },
      sources = {
        -- add lazydev to your completion providers
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        },
      }
    }
  }
  --   'hrsh7th/nvim-cmp',
  --   event = 'InsertEnter',
  --   dependencies = {
  --     { 'hrsh7th/cmp-buffer' },
  --     { 'hrsh7th/cmp-path' },
  --     { 'L3MON4D3/LuaSnip' },
  --   },
  --   config = function()
  --     local cmp = require('cmp')
  --     local cmp_select = { behavior = cmp.SelectBehavior.Select }
  --     local luasnip = require('luasnip')
  --     cmp.setup({
  --       sources = {
  --         { name = 'path' },
  --         { name = 'nvim_lsp' },
  --         { name = "crates" },
  --         { name = 'buffer',  keyword_length = 3 },
  --       },
  --       window = {
  --         completion = cmp.config.window.bordered(),
  --         documentation = cmp.config.window.bordered(),
  --       },
  --       snippet = {
  --         expand = function(args)
  --           luasnip.lsp_expand(args.body)
  --         end
  --       },
  --       mapping = {
  --         ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  --         ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  --         ['<C-d>'] = cmp.mapping.scroll_docs(8),
  --         ['<C-u>'] = cmp.mapping.scroll_docs(-8),
  --         ['<C-Space>'] = cmp.mapping.complete {},
  --         ['<CR>'] = cmp.mapping.confirm({ select = true }),
  --         ['<Tab>'] = cmp.mapping(function(fallback)
  --           if cmp.visible() then
  --             cmp.select_next_item(cmp_select)
  --           elseif luasnip.expand_or_locally_jumpable() then
  --             luasnip.expand_or_jump()
  --           else
  --             fallback()
  --           end
  --         end, { 'i', 's' }),
  --         ['<S-Tab>'] = cmp.mapping(function(fallback)
  --           if cmp.visible() then
  --             cmp.select_prev_item(cmp_select)
  --           elseif luasnip.locally_jumpable(-1) then
  --             luasnip.jump(-1)
  --           else
  --             fallback()
  --           end
  --         end, { 'i', 's' }),
  --       }
  --     })
  --   end
  -- },
}
