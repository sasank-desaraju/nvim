return {
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
      require("nvim-autopairs").remove_rule("`")
    end,
  },

  { -- completion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "saadparwaiz1/cmp_luasnip",
      "f3fora/cmp-spell",
      "ray-x/cmp-treesitter",
      "kdheepak/cmp-latex-symbols",
      "jmbuhr/cmp-pandoc-references",
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind-nvim",
      "jmbuhr/otter.nvim",
      "zbirenbaum/copilot-cmp",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert" },
        mapping = {
          ["<C-f>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
              fallback()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<c-y>"] = cmp.mapping.confirm({
            select = true,
          }),
          ["<CR>"] = cmp.mapping.confirm({
            select = false,
          }),
          -- ["<CR>"] = nil,

          ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
          ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),
        },
        autocomplete = true,

        sorting = {
          priority_weight = 2,
          comparators = {
            require("copilot_cmp.comparators").prioritize,

            -- Below is the default comparitor list and order for nvim-cmp
            cmp.config.compare.offset,
            -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },

        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol",
            menu = {
              copilot = "[copilot]",
              otter = "[🦦]",
              nvim_lsp = "[LSP]",
              luasnip = "[snip]",
              buffer = "[buf]",
              path = "[path]",
              spell = "[spell]",
              pandoc_references = "[ref]",
              tags = "[tag]",
              treesitter = "[TS]",
              calc = "[calc]",
              latex_symbols = "[tex]",
              emoji = "[emoji]",
            },
          }),
        },
        sources = {
          { name = "copilot" },
          { name = "otter" }, -- for code chunks in quarto
          { name = "path" },
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "luasnip", keyword_length = 3, max_item_count = 3 },
          { name = "pandoc_references" },
          { name = "buffer", keyword_length = 5, max_item_count = 3 },
          { name = "spell" },
          { name = "treesitter", keyword_length = 5, max_item_count = 3 },
          { name = "calc" },
          { name = "latex_symbols" },
          { name = "emoji" },
        },
        view = {
          entries = "native",
        },
        window = {
          documentation = {
            border = require("misc.style").border,
          },
        },
      })

      -- for friendly snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      -- for custom snippets
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snips" } })
      -- link quarto and rmarkdown to markdown snippets
      luasnip.filetype_extend("quarto", { "markdown" })
      luasnip.filetype_extend("rmarkdown", { "markdown" })
    end,
  },

  { -- copilot-cmp; makes copilot an LSP completion source
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  { -- gh copilot
    "zbirenbaum/copilot.lua",
    enabled = true,
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = false, -- recommended to disable by copilot-cmp
          auto_refresh = false,
        },
        suggestion = {
          enabled = false, -- recommended to disable by copilot-cmp
          auto_trigger = false,
          debounce = 75,
          keymap = {
            accept = "<c-a>",
            -- accept = false,
            accept_word = false,
            accept_line = false,
            -- accept_line = "<C-y>",
            next = "<M-]>",
            -- next = "<C-n>",
            prev = "<M-[>",
            -- prev = "<C-p>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
        },
      })
    end,
  },
}
-- let's see if this works; omg it does. This is so cool!!!
