local function enable_treesitter()
  local group = vim.api.nvim_create_augroup('local-treesitter-setup', { clear = true })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    callback = function(args)
      local language = vim.treesitter.language.get_lang(args.match) or args.match
      local ok, added = pcall(vim.treesitter.language.add, language)
      if not ok or not added then
        return
      end

      vim.treesitter.start(args.buf, language)

      if #vim.treesitter.query.get_files(language, 'indents') > 0 then
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end

      if language == 'latex' then
        vim.bo[args.buf].syntax = 'ON'
      end
    end,
  })
end


local function map_textobjects()
  local select = require 'nvim-treesitter-textobjects.select'
  local move = require 'nvim-treesitter-textobjects.move'

  vim.keymap.set({ 'x', 'o' }, 'af', function()
    select.select_textobject('@function.outer', 'textobjects')
  end, { desc = 'treesitter function outer' })
  vim.keymap.set({ 'x', 'o' }, 'if', function()
    select.select_textobject('@function.inner', 'textobjects')
  end, { desc = 'treesitter function inner' })
  vim.keymap.set({ 'x', 'o' }, 'ac', function()
    select.select_textobject('@class.outer', 'textobjects')
  end, { desc = 'treesitter class outer' })
  vim.keymap.set({ 'x', 'o' }, 'ic', function()
    select.select_textobject('@class.inner', 'textobjects')
  end, { desc = 'treesitter class inner' })

  vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
    move.goto_next_start('@function.outer', 'textobjects')
  end, { desc = 'next function start' })
  vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
    move.goto_next_start('@class.inner', 'textobjects')
  end, { desc = 'next class start' })
  vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
    move.goto_next_end('@function.outer', 'textobjects')
  end, { desc = 'next function end' })
  vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
    move.goto_next_end('@class.outer', 'textobjects')
  end, { desc = 'next class end' })
  vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
    move.goto_previous_start('@function.outer', 'textobjects')
  end, { desc = 'previous function start' })
  vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
    move.goto_previous_start('@class.inner', 'textobjects')
  end, { desc = 'previous class start' })
  vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
    move.goto_previous_end('@function.outer', 'textobjects')
  end, { desc = 'previous function end' })
  vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
    move.goto_previous_end('@class.outer', 'textobjects')
  end, { desc = 'previous class end' })
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    config = function()
      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath('data') .. '/site',
      }
      -- Async; already-installed parsers are skipped.
      require('nvim-treesitter').install {
        'r', 'python', 'markdown', 'markdown_inline', 'julia', 'bash', 'yaml',
        'lua', 'vim', 'query', 'vimdoc', 'latex', 'html', 'css', 'dot',
        'javascript', 'mermaid', 'typescript',
      }
      enable_treesitter()
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    lazy = false,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }
      map_textobjects()
    end,
  },
}
