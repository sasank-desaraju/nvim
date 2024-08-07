-- plugins for notetaking and knowledge management

return {

  {
    'nvim-neorg/neorg',
    enabled = false,
    config = function()
      require('neorg').setup {}
    end,
  },

  {
    'jakewvincent/mkdnflow.nvim',
    enabled = false,
    config = function()
      local mkdnflow = require 'mkdnflow'
      mkdnflow.setup {}
    end,
  },

  {
    'epwalsh/obsidian.nvim',
    enabled = true,
    lazy = false,
    ft = 'markdown',
    event = {
      -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
      'BufReadPre ' .. vim.fn.expand '~/Documents/Obsidian_ROOT/Primary/**/*.md',
      'BufNewFile ' .. vim.fn.expand '~/Documents/Obsidian_ROOT/Primary/**/*.md',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    templates = {
      -- folder = 'Templates',
      folder = 'Templates',
      date_format = '%Y-%m-%d-%a',
      time_format = '%H:%M',
    },
    ui = {
      enable = true, -- set to false to disable all additional syntax features
      update_debounce = 200, -- update delay after a text change (in milliseconds)
      max_file_length = 5000, -- disable UI features for files with more than this many lines
      -- Define how various check-boxes are displayed
      checkboxes = {
        -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
        [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
        ['x'] = { char = '', hl_group = 'ObsidianDone' },
        -- [">"] = { char = "", hl_group = "ObsidianRightArrow" },
        -- ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        -- ["!"] = { char = "", hl_group = "ObsidianImportant" },
        -- Replace the above with this if you don't have a patched font:
        -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
        -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

        -- You can also add more custom ones...
      },
    },
    keys = {
      { '<leader>;', ':ObsidianToggleCheckbox<cr>', desc = 'toggle checkboxes' },
      -- { '<leader>nd', ':ObsidianToday<cr>', desc = 'obsidian [d]aily' },
      -- { '<leader>nt', ':ObsidianToday 1<cr>', desc = 'obsidian [t]omorrow' },
      -- { '<leader>ny', ':ObsidianToday -1<cr>', desc = 'obsidian [y]esterday' },
      -- { '<leader>nb', ':ObsidianBacklinks<cr>', desc = 'obsidian [b]acklinks' },
      -- { '<leader>nl', ':ObsidianLink<cr>', desc = 'obsidian [l]ink selection' },
      -- { '<leader>nf', ':ObsidianFollowLink<cr>', desc = 'obsidian [f]ollow link' },
      -- { '<leader>nn', ':ObsidianNew<cr>', desc = 'obsidian [n]ew' },
      -- { '<leader>ns', ':ObsidianSearch<cr>', desc = 'obsidian [s]earch' },
      -- { '<leader>no', ':ObsidianQuickSwitch<cr>', desc = 'obsidian [o]pen quickswitch' },
      -- { '<leader>nO', ':ObsidianOpen<cr>', desc = 'obsidian [O]pen in app' },
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('obsidian').setup {
        workspaces = {
          {
            name = 'Primary',
            path = '~/Documents/Obsidian_ROOT/Primary/',
          },
        },
        mappings = {
          -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
          ['gf'] = {
            action = function()
              return require('obsidian').util.gf_passthrough()
            end,
            opts = { noremap = false, expr = true, buffer = true },
          },
          -- create and toggle checkboxes
          ['<c-;>'] = {
            action = function()
              local line = vim.api.nvim_get_current_line()
              if line:match '%s*- %[' then
                require('obsidian').util.toggle_checkbox()
              elseif line:match '%s*-' then
                vim.cmd [[s/-/- [ ]/]]
                vim.cmd.nohlsearch()
              end
            end,
            opts = { buffer = true },
          },
        },
        -- Optional, customize how names/IDs for new notes are created.
        note_id_func = function(title)
          -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
          -- In this case a note with the title 'My new note' will be given an ID that looks
          -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
          local suffix = ''
          if title ~= nil then
            -- If title is given, transform it into valid file name.
            suffix = title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
          else
            -- If title is nil, just add 4 random uppercase letters to the suffix.
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          return tostring(os.time()) .. '-' .. suffix
        end,
      }

      vim.wo.conceallevel = 1
    end,
  },
  {
    -- INFO: This mirrors navigation events in Neovim in the Obsidian app.
    'oflisback/obsidian-bridge.nvim',
    enabled = false,
  },
}
