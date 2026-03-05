return {
  'hrsh7th/nvim-cmp',

  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',

    'onsails/lspkind.nvim',

    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',

    {
      "David-Kunz/cmp-npm",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("cmp-npm").setup({})
      end,
    },

    "b0o/schemastore.nvim",

  },

  config = function()
    local cmp = require('cmp')

    local lspkind = require('lspkind')
    local luasnip = require('luasnip')

    local mapping = {
      ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-s>'] = cmp.mapping.complete({}),
      ['<C-u>'] = cmp.mapping.scroll_docs(4),
      ['<C-c>'] = cmp.mapping.abort(), -- <C-c> statt <C-e> aus deinem Upload
      ['<CR>'] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },

      mapping = mapping,

      sources = cmp.config.sources({
        { name = 'nvim_lsp_signature_help' },
        { name = 'npm',                    keyword_length = 4 },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
      }),

      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol_text',
          maxwidth = 50,
          ellipsis_char = '...',
        }),
      },

      preselect = 'item',
      completion = {
        completeopt = 'menu,menuone,noinsert'
      },
    })

    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' },
        { name = 'cmdline' },
      }),
    })
    cmp.setup.cmdline('/', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' },
      },
    })
  end,
}
