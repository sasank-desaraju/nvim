-- git plugins

return {
  { 'sindrets/diffview.nvim' },

  -- { "tpope/vim-fugitive" },    # Apparently Neogit is fugitive++

  -- handy git ui
  -- local neogit = require('neogit')
  -- vim.keymap.set("n", "<leader>gg", neogit.open,
  --   {silent = true, noremap = true}
  -- )
  {
    'NeogitOrg/neogit',
    lazy = true,
    cmd = 'Neogit',
    -- keys = {
    --   { '<leader>gg', ':Neogit<cr>', desc = 'neo[g]it' },
    -- },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('neogit').setup {
        disable_commit_confirmation = true,
        integrations = {
          diffview = true,
        },
        disable_line_numbers = false,
        kind = 'split',
        commit_select_view = {
          kind = 'floating',
        },
        commit_view = {
          kind = 'split',
          verify_commit = vim.fn.executable 'gpg' == 1, -- Can be set to true or false, otherwise we try to find the binary
        },
        log_view = {
          kind = 'vsplit',
        },
        -- rebase_editor = {
        --   kind = "auto",
        -- },
        reflog_view = {
          kind = 'vsplit',
        },
        -- merge_editor = {
        --   kind = "auto",
        -- },
        -- tag_editor = {
        --   kind = "auto",
        -- },
        preview_buffer = {
          kind = 'split',
        },
        popup = {
          kind = 'split',
        },
        mappings = {
          status = {
            ['k'] = 'MoveUp',
          },
        },
      }
    end,
  },

  {
    'lewis6991/gitsigns.nvim',
    enabled = true,
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '┃' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
          untracked = { text = '┆' },
        },
        sign_priority = 100,
        preview_config = {
          -- Options passed to nvim_open_win
          border = 'single',
          style = 'minimal',
          relative = 'cursor',
          row = 0,
          col = 1,
        },
        on_attach = function(bufnr)
          local gitsigns = require 'gitsigns'

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal { ']c', bang = true }
            else
              gitsigns.nav_hunk 'next'
            end
          end)

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal { '[c', bang = true }
            else
              gitsigns.nav_hunk 'prev'
            end
          end)

          -- Actions
          map('n', '<leader>hs', gitsigns.stage_hunk)
          map('n', '<leader>hr', gitsigns.reset_hunk)
          map('v', '<leader>hs', function()
            gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end)
          map('v', '<leader>hr', function()
            gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end)
          map('n', '<leader>hS', gitsigns.stage_buffer)
          map('n', '<leader>hu', gitsigns.undo_stage_hunk)
          map('n', '<leader>hR', gitsigns.reset_buffer)
          map('n', '<leader>hp', gitsigns.preview_hunk)
          map('n', '<leader>hb', function()
            gitsigns.blame_line { full = true }
          end)
          map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
          map('n', '<leader>hd', gitsigns.diffthis)
          map('n', '<leader>hD', function()
            gitsigns.diffthis '~'
          end)
          map('n', '<leader>td', gitsigns.toggle_deleted)

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end,
      }
    end,
  },
  {
    'akinsho/git-conflict.nvim',
    init = function()
      require('git-conflict').setup {
        default_mappings = false,
        disable_diagnostics = true,
      }
    end,
    keys = {
      { '<leader>gco', ':GitConflictChooseOurs<cr>' },
      { '<leader>gct', ':GitConflictChooseTheirs<cr>' },
      { '<leader>gcb', ':GitConflictChooseBoth<cr>' },
      { '<leader>gc0', ':GitConflictChooseNone<cr>' },
      { ']x', ':GitConflictNextConflict<cr>' },
      { '[x', ':GitConflictPrevConflict<cr>' },
    },
  },
  {
    -- TODO: Not sure if this is better than Gitsigns' git blame or not. They have different sytles but that's it.
    'f-person/git-blame.nvim',
    init = function()
      require('gitblame').setup {
        enabled = false,
      }
      vim.g.gitblame_display_virtual_text = 1
      -- vim.g.gitblame_enabled = 0
    end,
  },

  {
    'kdheepak/lazygit.nvim',
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    -- optional for floating window border decoration
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    -- keys = {
    --   { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    -- }
  },

  { -- github PRs and the like with gh - cli
    'pwntester/octo.nvim',
    enabled = false,
    cmd = 'Octo',
    config = function()
      require('octo').setup()
      vim.keymap.set('n', '<leader>gpl', ':Octo pr list<cr>', { desc = 'octo [p]r list' })
      vim.keymap.set('n', '<leader>gpr', ':Octo review start<cr>', { desc = 'octo [r]eview' })
    end,
  },
}
