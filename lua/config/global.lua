-- global options

-- disable line wrapping to make log files look good
if env.is_hpc then
  vim.o.wrap = false
end

-- TODO: Get relative line numbers when I press/hold Ctrl

local animals = require('misc.style').animals

-- makes copilot not complete with tab according to CopilotChat.nvim
vim.g.copilot_no_tab_map = true

-- proper colors
vim.opt.termguicolors = true

-- show insert mode in terminal buffers
vim.api.nvim_set_hl(0, 'TermCursor', { fg = '#A6E3A1', bg = '#A6E3A1' })

-- disable fill chars (the ~ after the buffer)
vim.o.fillchars = 'eob: '

-- more opinionated
vim.opt.number = true -- show linenumbers
vim.opt.mouse = 'a' -- enable mouse
vim.opt.mousefocus = true

if env.is_hpc then
  vim.g.clipboard = {
    name = 'tmux',
    copy = {
      ['+'] = 'tmux load-buffer -',
      ['*'] = 'tmux load-buffer -',
    },
    paste = {
      ['+'] = 'tmux save-buffer -',
      ['*'] = 'tmux save-buffer -',
    },
    cache_enabled = true,
  }
elseif vim.fn.executable 'wl-copy' == 1 and vim.env.WAYLAND_DISPLAY then
  vim.g.clipboard = {
    name = 'wl-clipboard',
    copy = {
      ['+'] = 'wl-copy --foreground --type text/plain',
      ['*'] = 'wl-copy --foreground --primary --type text/plain',
    },
    paste = {
      ['+'] = 'wl-paste --no-newline',
      ['*'] = 'wl-paste --no-newline --primary',
    },
    cache_enabled = true,
  }
  vim.opt.clipboard = 'unnamedplus'
elseif vim.fn.executable 'xsel' == 1 and vim.env.DISPLAY then
  vim.g.clipboard = {
    name = 'xsel',
    copy = {
      ['+'] = 'xsel --clipboard --input',
      ['*'] = 'xsel --primary --input',
    },
    paste = {
      ['+'] = 'xsel --clipboard --output',
      ['*'] = 'xsel --primary --output',
    },
    cache_enabled = true,
  }
  vim.opt.clipboard = 'unnamedplus'
elseif vim.fn.executable 'xclip' == 1 and vim.env.DISPLAY then
  vim.g.clipboard = {
    name = 'xclip',
    copy = {
      ['+'] = 'xclip -selection clipboard -in',
      ['*'] = 'xclip -selection primary -in',
    },
    paste = {
      ['+'] = 'xclip -selection clipboard -out',
      ['*'] = 'xclip -selection primary -out',
    },
    cache_enabled = true,
  }
  vim.opt.clipboard = 'unnamedplus'
end

vim.opt.timeoutlen = 400 -- until which-key pops up
vim.opt.updatetime = 250 -- for autocommands and hovers

-- don't ask about existing swap files
vim.opt.shortmess:append 'A'

-- mode is already in statusline
vim.opt.showmode = false

-- indentation
local tabsize = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = tabsize
vim.opt.tabstop = tabsize

-- Quickfix doesn't switch cursor to it automatically
vim.g.vimtex_quickfix_autojump = 0

-- space as leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- smarter search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- indent
vim.opt.smartindent = true
vim.opt.breakindent = true

-- Sets how neovim will display certain whitespace in the editor.
--  See :help 'list'
--  and :help 'listchars'
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- consistent number column
vim.opt.signcolumn = 'yes:1'

-- how to show autocomplete menu
vim.opt.completeopt = 'menuone,noinsert'

-- global statusline
vim.opt.laststatus = 3

vim.cmd [[
let g:currentmode={
       \ 'n'  : '%#String# NORMAL ',
       \ 'v'  : '%#Search# VISUAL ',
       \ 's'  : '%#ModeMsg# VISUAL ',
       \ "\<C-V>" : '%#Title# V·Block ',
       \ 'V'  : '%#IncSearch# V·Line ',
       \ 'Rv' : '%#String# V·Replace ',
       \ 'i'  : '%#ModeMsg# INSERT ',
       \ 'R'  : '%#Substitute# R ',
       \ 'c'  : '%#CurSearch# Command ',
       \ 't'  : '%#ModeMsg# TERM ',
       \}
]]

math.randomseed(os.time())
local i = math.random(#animals)
vim.opt.statusline = '%{%g:currentmode[mode()]%} %{%reg_recording()%} %* %t | %y | %* %= c:%c l:%l/%L %p%% %#NonText# ' .. animals[i] .. ' %*'

-- hide cmdline when not used
vim.opt.cmdheight = 1

-- split right and below by default
vim.opt.splitright = true
vim.opt.splitbelow = true

--tabline
vim.opt.showtabline = 1

--windowline
vim.opt.winbar = '%f'

-- don't continue comments automagically
-- https://neovim.io/doc/user/options.html#'formatoptions'
vim.opt.formatoptions:remove 'c'
vim.opt.formatoptions:remove 'r'
vim.opt.formatoptions:remove 'o'

-- scroll before end of window
vim.opt.scrolloff = 2

-- (don't == 0) replace certain elements with prettier ones
vim.opt.conceallevel = 0

-- diagnostics
vim.diagnostic.config {
  virtual_text = true,
  underline = true,
  signs = true,
}

-- TODO: add Python, YAML, maybe others?
-- add new filetypes
vim.filetype.add {
  extension = {
    -- ojs = 'javascript',
  },
  pattern = {
    ['.*/qmd/.*%.md'] = 'quarto',
  },
}

-- additional builtin vim packages
-- filter quickfix list with Cfilter
vim.cmd.packadd 'cfilter'
