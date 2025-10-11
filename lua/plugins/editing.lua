return {

  -- disables hungry features for files larget than 2MB
  { 'LunarVim/bigfile.nvim' },

  -- add/delete/change can be done with the keymaps
  -- ys{motion}{char}, ds{char}, and cs{target}{replacement}
  {
    'kylechui/nvim-surround',
    enabled = true,
    event = 'VeryLazy',
    opts = {},
  },

  {
    'numToStr/Comment.nvim',
    version = nil,
    branch = 'master',
    config = true,
  },

  { -- format things as tables
    'godlygeek/tabular',
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    enabled = false,
    config = function()
      require('conform').setup {
        notify_on_error = false,
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters_by_ft = {
          lua = { 'mystylua' },
          python = { 'isort', 'black' },
        },
        formatters = {
          mystylua = {
            command = 'stylua',
            args = { '--indent-type', 'Spaces', '--indent-width', '2', '-' },
          },
        },
      }
      -- Customize the "injected" formatter
      require('conform').formatters.injected = {
        -- Set the options field
        options = {
          -- Set to true to ignore errors
          ignore_errors = false,
          -- Map of treesitter language to file extension
          -- A temporary file name with this extension will be generated during formatting
          -- because some formatters care about the filename.
          lang_to_ext = {
            bash = 'sh',
            c_sharp = 'cs',
            elixir = 'exs',
            javascript = 'js',
            julia = 'jl',
            latex = 'tex',
            markdown = 'md',
            python = 'py',
            ruby = 'rb',
            rust = 'rs',
            teal = 'tl',
            r = 'r',
            typescript = 'ts',
          },
          -- Map of treesitter language to formatters to use
          -- (defaults to the value from formatters_by_ft)
          lang_to_formatters = {},
        },
      }
    end,
  },

  { -- generate docstrings
    'danymat/neogen',
    cmd = { 'Neogen' },
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = true,
  },

  {
    'chrishrb/gx.nvim',
    keys = { { 'gx', '<cmd>Browse<cr>', mode = { 'n', 'x' } } },
    cmd = { 'Browse' },
    init = function()
      vim.g.netrw_nogx = 1 -- disable netrw gx
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
    submodules = false, -- not needed, submodules are required only for tests
    opts = {
      handler_options = {
        -- you can select between google, bing, duckduckgo, and ecosia
        search_engine = 'duckduckgo',
      },
    },
  },

  -- plugins for getting around text faster. Going to try hop, flash, leap
  {
    'folke/flash.nvim',
    enabled = true,
    event = 'VeryLazy',
    opts = {
      modes = {
        search = {
          enabled = false,
        },
      },
    },
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
      },
      {
        'S',
        mode = { 'o', 'x' },
        function()
          require('flash').treesitter()
        end,
      },
    },
  },

  -- interactive global search and replace
  {
    'nvim-pack/nvim-spectre',
    cmd = { 'Spectre' },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
    opts = {
      file_types = { "markdown", "Avante" },
    },
    ft = { "markdown", "Avante" },
  },

  {
    "lervag/vimtex",
    lazy = false,     -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      -- vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_quickfix_autojump = 0
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
          "-file-line-error",
          -- "-use-biber",
        },
      }
    end
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    enabled = true,
  },
}
