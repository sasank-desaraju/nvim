return {
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
    -- keys = {
    --   { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", mode = "n", desc = "Left Tmux pane" },
    --   { "<C-l>", "<cmd>TmuxNavigateRight<cr>", mode = "n", desc = "Right Tmux pane" },
    --   { "<C-j>", "<cmd>TmuxNavigateDown<cr>", mode = "n", desc = "Down Tmux pane" },
    --   { "<C-k>", "<cmd>TmuxNavigateUp<cr>", mode = "n", desc = "Up Tmux pane" },
    -- },
  },
  -- telescope
  -- a nice seletion UI also to find and open files
  {
    'nvim-telescope/telescope.nvim',
    -- lazy = false,   -- set lazy to false for telescope-cmdline
    dependencies = {
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-dap.nvim' },
      -- { "jonarrien/telescope-cmdline.nvim" },
      {
        'jmbuhr/telescope-zotero.nvim',
        enabled = true,
        dev = false,
        dependencies = {
          { 'kkharji/sqlite.lua' },
        },
        config = function()
          vim.keymap.set('n', '<leader>fz', ':Telescope zotero<cr>', { desc = '[z]otero' })
        end,
      },
    },
    -- keys = {
    --   { ":", "<cmd>Telescope cmdline<cr>", mode = "n", desc = "Cmdline" },
    -- },
    -- INFO: What does this do?
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'
      local previewers = require 'telescope.previewers'
      local new_maker = function(filepath, bufnr, opts)
        opts = opts or {}
        filepath = vim.fn.expand(filepath)
        vim.loop.fs_stat(filepath, function(_, stat)
          if not stat then
            return
          end
          if stat.size > 100000 then
            return
          else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
          end
        end)
      end

      local telescope_config = require 'telescope.config'
      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescope_config.values.vimgrep_arguments) }
      -- I don't want to search in the `docs` directory (rendered quarto output).
      table.insert(vimgrep_arguments, '--glob')
      table.insert(vimgrep_arguments, '!docs/*')

      telescope.setup {
        defaults = {
          buffer_previewer_maker = new_maker,
          vimgrep_arguments = vimgrep_arguments,
          file_ignore_patterns = {
            'node_modules',
            '%_files/',
            '%_cache',
            '.git/',
            'site_libs',
            '.venv',
          },
          layout_strategy = 'flex',
          sorting_strategy = 'ascending',
          layout_config = {
            prompt_position = 'top',
          },
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['<C-k>'] = actions.preview_scrolling_up,
              ['<C-j>'] = actions.preview_scrolling_down,
              ['<esc>'] = actions.close,
              ['<c-n>'] = actions.move_selection_next,
              ['<c-p>'] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = false,
            find_command = {
              'rg',
              '--files',
              '--hidden',
              '--glob',
              '!.git/*',
              '--glob',
              '!**/.Rpro.user/*',
              '--glob',
              '!_site/*',
              '--glob',
              '!docs/**/*.html',
              '-L',
            },
          },
          buffers = {
            -- sort_lastused = true,
            -- theme = 'dropdown',
            -- previewer = true,
            mappings = {
              i = {
                ['<c-d>'] = actions.delete_buffer,
              },
              n = {
                ['<c-d>'] = actions.delete_buffer,
              },
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
          },
        },
      }
      telescope.load_extension 'fzf'
      telescope.load_extension 'ui-select'
      telescope.load_extension 'dap'
      telescope.load_extension 'zotero'
      -- telescope.load_extension("cmdline")
    end,
  },

  -- TODO: Add the comment highlights I want
  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      -- basic telescope configuration
      local conf = require('telescope.config').values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require('telescope.pickers')
          .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end

      vim.keymap.set('n', '<leader>ha', function()
        harpoon:list():add()
      end)
      vim.keymap.set('n', '<leader>hl', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
        -- toggle_telescope(harpoon:list())
      end, { desc = 'Open harpoon window' })

      vim.keymap.set('n', '<leader>1', function()
        harpoon:list():select(1)
      end)
      vim.keymap.set('n', '<leader>2', function()
        harpoon:list():select(2)
      end)
      vim.keymap.set('n', '<leader>3', function()
        harpoon:list():select(3)
      end)
      vim.keymap.set('n', '<leader>4', function()
        harpoon:list():select(4)
      end)

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-S-P>', function()
        harpoon:list():prev()
      end)
      vim.keymap.set('n', '<C-S-N>', function()
        harpoon:list():next()
      end)

      -- not even Harpoon; just getting similar functionality with global marks
      -- vim.keymap.set('n', '<c-1>', 'mA') -- set a global mark with ctrl+1
      -- vim.keymap.set('n', '<s-1>', 'A') -- go to a global mark with shift+1
      -- vim.keymap.set('n', '<c-2>', 'mB')
      -- vim.keymap.set('n', '<s-2>', 'B')
      -- vim.keymap.set('n', '<c-3>', 'mC')
      -- vim.keymap.set('n', '<s-3>', 'C')
      -- vim.keymap.set('n', '<c-4>', 'mD')
      -- vim.keymap.set('n', '<s-4>', 'D')
    end,
  },

  { -- edit the file system as a buffer
    'stevearc/oil.nvim',
    opts = {
      keymaps = {
        ['<C-s>'] = false,
        ['<C-h>'] = false,
        ['<C-l>'] = false,
      },
      view_options = {
        show_hidden = true,
      },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '-', ':Oil<cr>', desc = 'oil' },
      { '<leader>ef', ':Oil<cr>', desc = 'edit [f]iles' },
    },
    cmd = 'Oil',
  },

  { -- statusline
    -- PERF: I found this to slow down the editor
    'nvim-lualine/lualine.nvim',
    enabled = false,
    config = function()
      local function macro_recording()
        local reg = vim.fn.reg_recording()
        if reg == '' then
          return ''
        end
        return '📷[' .. reg .. ']'
      end

      ---@diagnostic disable-next-line: undefined-field
      require('lualine').setup {
        options = {
          section_separators = '',
          component_separators = '',
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode', macro_recording },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          -- lualine_b = {},
          lualine_c = { 'searchcount' },
          lualine_x = { 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        extensions = { 'nvim-tree' },
      }
    end,
  },

  { -- nicer-looking tabs with close icons
    'nanozuki/tabby.nvim',
    enabled = false,
    config = function()
      require('tabby.tabline').use_preset 'tab_only'
    end,
  },

  { -- scrollbar
    'dstein64/nvim-scrollview',
    enabled = true,
    opts = {
      current_only = true,
    },
  },

  { -- highlight occurences of current word
    'RRethy/vim-illuminate',
    enabled = false,
  },

  { -- filetree
    'nvim-tree/nvim-tree.lua',
    enabled = false,
    keys = {
      { '<leader>n', ':NvimTreeToggle<cr>', desc = 'toggle nvim-tree' },
    },
    config = function()
      require('nvim-tree').setup {
        disable_netrw = true,
        update_focused_file = {
          enable = true,
        },
        git = {
          enable = true,
          ignore = false,
          timeout = 500,
        },
        diagnostics = {
          enable = true,
        },
      }
    end,
  },

  -- or a different filetree
  {
    -- INFO: Okay, this is nice >:)
    'nvim-neo-tree/neo-tree.nvim',
    enabled = true,
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<leader>n', ':Neotree toggle<cr>', desc = 'Toggle neo-tree' },
      -- { "<C-p>", "scroll_preview", config = { direction = 10 } },
      -- { "<C-n>", "scroll_preview", config = { direction = -10 } },
    },
    config = function()
      require('neo-tree').setup {
        window = {
          mappings = {
            ['<C-j>'] = { 'scroll_preview', config = { direction = -10 } },
            ['<C-k>'] = { 'scroll_preview', config = { direction = 10 } },
          },
        },
      }
    end,
  },

  -- show keybinding help window
  {
    'folke/which-key.nvim',
    enabled = true,
    config = function()
      require('which-key').setup {}
      require 'config.keymap'
    end,
  },

  { -- show tree of symbols in the current file
    'simrat39/symbols-outline.nvim',
    cmd = 'SymbolsOutline',
    keys = {
      { '<leader>lo', ':SymbolsOutline<cr>', desc = 'symbols outline' },
    },
    opts = {},
  },

  { -- or show symbols in the current file as breadcrumbs
    'Bekaboo/dropbar.nvim',
    enabled = function()
      return vim.fn.has 'nvim-0.10' == 1
    end,
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
    },
    config = function()
      -- turn off global option for windowline
      vim.opt.winbar = nil
      vim.keymap.set('n', '<leader>ls', require('dropbar.api').pick, { desc = '[s]ymbols' })
    end,
  },

  { -- floating terminal
    'akinsho/toggleterm.nvim',
    opts = {
      open_mapping = [[<c-\>]],
      direction = 'float',
      size = 10,
      shade_terminals = true,
    },
  },

  { -- show diagnostics list
    -- PERF: Slows down insert mode if open and there are many diagnostics
    'folke/trouble.nvim',
    enabled = false,
    config = function()
      local trouble = require 'trouble'
      trouble.setup {}
      local function next()
        trouble.next { skip_groups = true, jump = true }
      end
      local function previous()
        trouble.previous { skip_groups = true, jump = true }
      end
      vim.keymap.set('n', ']t', next, { desc = 'next [t]rouble item' })
      vim.keymap.set('n', '[t', previous, { desc = 'previous [t]rouble item' })
    end,
  },

  { -- show indent lines
    'lukas-reineke/indent-blankline.nvim',
    enabled = false,
    main = 'ibl',
    opts = {
      indent = { char = '│' },
    },
  },

  { -- highlight markdown headings and code blocks etc.
    'lukas-reineke/headlines.nvim',
    enabled = false,
    dependencies = 'nvim-treesitter/nvim-treesitter',
    config = function()
      require('headlines').setup {
        quarto = {
          query = vim.treesitter.query.parse(
            'markdown',
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = 'CodeBlock',
          treesitter_language = 'markdown',
        },
        markdown = {
          query = vim.treesitter.query.parse(
            'markdown',
            [[
                (fenced_code_block) @codeblock
                ]]
          ),
          codeblock_highlight = 'CodeBlock',
        },
      }
    end,
  },

  -- TODO: This seems cool to get working
  { -- show images in nvim!
    '3rd/image.nvim',
    enabled = false,
    dev = false,
    ft = { 'markdown', 'quarto', 'vimwiki' },
    dependencies = {
      {
        'vhyrro/luarocks.nvim',
        priority = 1001, -- this plugin needs to run before anything else
        opts = {
          rocks = { 'magick' },
        },
      },
    },
    config = function()
      -- Requirements
      -- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
      -- check for dependencies with `:checkhealth kickstart`
      -- needs:
      -- sudo apt install imagemagick
      -- sudo apt install libmagickwand-dev
      -- sudo apt install liblua5.1-0-dev
      -- sudo apt installl luajit

      local image = require 'image'
      image.setup {
        backend = 'kitty',
        integrations = {
          markdown = {
            enabled = true,
            only_render_image_at_cursor = true,
            filetypes = { 'markdown', 'vimwiki', 'quarto' },
          },
        },
        editor_only_render_when_focused = false,
        window_overlap_clear_enabled = true,
        -- window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview' },
        tmux_show_only_in_active_window = true,
        window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview', 'scrollview_sign' },
        max_width = nil,
        max_height = nil,
        max_width_window_percentage = nil,
        max_height_window_percentage = 30,
        kitty_method = 'normal',
      }

      local function clear_all_images()
        local bufnr = vim.api.nvim_get_current_buf()
        local images = image.get_images { buffer = bufnr }
        for _, img in ipairs(images) do
          img:clear()
        end
      end

      local function get_image_at_cursor(buf)
        local images = image.get_images { buffer = buf }
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        for _, img in ipairs(images) do
          if img.geometry ~= nil and img.geometry.y == row then
            local og_max_height = img.global_state.options.max_height_window_percentage
            img.global_state.options.max_height_window_percentage = nil
            return img, og_max_height
          end
        end
        return nil
      end

      local create_preview_window = function(img, og_max_height)
        local buf = vim.api.nvim_create_buf(false, true)
        local win_width = vim.api.nvim_get_option_value('columns', {})
        local win_height = vim.api.nvim_get_option_value('lines', {})
        local win = vim.api.nvim_open_win(buf, true, {
          relative = 'editor',
          style = 'minimal',
          width = win_width,
          height = win_height,
          row = 0,
          col = 0,
          zindex = 1000,
        })
        vim.keymap.set('n', 'q', function()
          vim.api.nvim_win_close(win, true)
          img.global_state.options.max_height_window_percentage = og_max_height
        end, { buffer = buf })
        return { buf = buf, win = win }
      end

      local handle_zoom = function(bufnr)
        local img, og_max_height = get_image_at_cursor(bufnr)
        if img == nil then
          return
        end

        local preview = create_preview_window(img, og_max_height)
        image.hijack_buffer(img.path, preview.win, preview.buf)
      end

      vim.keymap.set('n', '<leader>io', function()
        local bufnr = vim.api.nvim_get_current_buf()
        handle_zoom(bufnr)
      end, { buffer = true, desc = 'image [o]pen' })

      vim.keymap.set('n', '<leader>ic', clear_all_images, { buffer = true, desc = 'image [c]lear' })
    end,
  },

  {
    -- TODO: stop the noice feature where treesitter (?) goes crazy on the right hand side whenever I'm typing
    'folke/noice.nvim',
    enabled = 'false',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
    config = function()
      require('noice').setup {
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          -- command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
        },
      }
    end,
  },
}
