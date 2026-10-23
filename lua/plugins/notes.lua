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
    -- INFO: No vault on HPG or fresh server installs.
    enabled = not env.is_hpc and env.has_obsidian_vault,
    lazy = false,
    ft = 'markdown',
    event = {
      -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      -- The below events are when the plugin will be loaded.
      -- I am disabling it because I want it always on anyway
      -- E.g. 'BufReadPre ' .. env.obsidian_vault .. '/**/*.md'
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
      'nvim-telescope/telescope.nvim',
      'nvim-treesitter/nvim-treesitter',
    },

    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('obsidian').setup {

        workspaces = {
          {
            name = 'Primary',
            path = env.obsidian_vault,
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

          -- Smart action depending on context, either follow link or toggle checkbox.
          ["<cr>"] = {
            action = function()
              return require("obsidian").util.smart_action()
            end,
            opts = { buffer = true, expr = true },
          }
        },


        templates = {
          folder = 'Templates',
          date_format = '%Y-%m-%d-%a',
          time_format = '%H:%M',
        },

        daily_notes = {
          -- Optional, if you keep daily notes in a separate directory.
          folder = "Temporal Notes/Daily Notes",
          -- Optional, if you want to change the date format for the ID of daily notes.
          date_format = "%Y-%m-%d",
          -- Optional, if you want to change the date format of the default alias of daily notes.
          -- alias_format = "%B %-d, %Y",
          -- Optional, default tags to add to each new daily note created.
          default_tags = { "daily-notes" },
          -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
          template = env.obsidian_vault .. "/Templates/Temporal Notes/Daily Notes Template.md",
        },

        -- Either 'wiki' or 'markdown'.
        preferred_link_style = "wiki",

        -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
        completion = {
          -- Set to false to disable completion.
          nvim_cmp = true,
          -- Trigger completion at 2 chars.
          min_chars = 2,
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

        picker = {
          -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
          name = "telescope.nvim",
          -- Optional, configure key mappings for the picker. These are the defaults.
          -- Not all pickers support all mappings.
          note_mappings = {
            -- Create a new note from your query.
            new = "<C-x>",
            -- Insert a link to the selected note.
            insert_link = "<C-l>",
          },
          tag_mappings = {
            -- Add tag(s) to current note.
            tag_note = "<C-x>",
            -- Insert a tag at the current location.
            insert_tag = "<C-l>",
          },
        },
        
        -- Optional, alternatively you can customize the frontmatter data.
        ---@return table
        note_frontmatter_func = function(note)
          -- Add the title of the note as an alias.
          -- if note.title then
          --   note:add_alias(note.title)
          -- end

          -- local out = { id = note.id, aliases = note.aliases, tags = note.tags }
          local out = { title = note.title, aliases = note.aliases, tags = note.tags }

          -- `note.metadata` contains any manually added fields in the frontmatter.
          -- So here we just make sure those fields are kept in the frontmatter.
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end

          return out
        end,

        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
        -- URL it will be ignored but you can customize this behavior here.
        ---@param url string
        follow_url_func = function(url)
          -- Open the URL in the default web browser.
          -- vim.fn.jobstart({"open", url})  -- Mac OS
          vim.fn.jobstart({"xdg-open", url})  -- linux
          -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
          -- vim.ui.open(url) -- need Neovim 0.10.0+
        end,

        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
        -- file it will be ignored but you can customize this behavior here.
        ---@param img string
        follow_img_func = function(img)
          -- vim.fn.jobstart { "qlmanage", "-p", img }  -- Mac OS quick look preview
          vim.fn.jobstart({"xdg-open", url})  -- linux
          -- vim.cmd(':silent exec "!start ' .. url .. '"') -- Windows
        end,

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
    enabled = true,
  },
  {
    ---@module "csvview"
    ---@type CsvView.Options
    'hat0uma/csvview.nvim',
    enabled = true,
    lazy = false,
    opts = {
      parser = { comments = { "#", "//" } },
      keymaps = {
        -- -- Text objects for selecting fields
        -- textobject_field_inner = { "if", mode = { "o", "x" } },
        -- textobject_field_outer = { "af", mode = { "o", "x" } },
        -- -- Excel-like navigation:
        -- -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        -- jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        -- jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        -- jump_next_row = { "<Enter>", mode = { "n", "v" } },
        -- jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  },
}
