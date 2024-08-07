-- global options

-- TODO: Get relative line numbers when I press/hold Ctrl

local animals = require("misc.style").animals

-- proper colors
vim.opt.termguicolors = true

-- show insert mode in terminal buffers
vim.api.nvim_set_hl(0, "TermCursor", { fg = "#A6E3A1", bg = "#A6E3A1" })

-- disable fill chars (the ~ after the buffer)
vim.o.fillchars = "eob: "

-- more opinionated
vim.opt.number = true -- show linenumbers
vim.opt.mouse = "a" -- enable mouse
vim.opt.mousefocus = true
-- -- Function to copy text to the system clipboard using tmux
-- local function copy_to_clipboard(lines, _)
--   local joined_lines = table.concat(lines, "\n")
--   local tmux_cmd = "tmux load-buffer -"
--   local handle = io.popen(tmux_cmd, "w")
--   if handle then
--     handle:write(joined_lines)
--     handle:close()
--   end
-- end
--
-- -- Function to paste text from the system clipboard using tmux
-- local function paste_from_clipboard()
--   local tmux_cmd = "tmux save-buffer -"
--   local handle = io.popen(tmux_cmd, "r")
--   local result = ""
--   if handle then
--     result = handle:read("*a")
--     handle:close()
--   end
--   return vim.split(result, "\n", { trimempty = true })
-- end
--
-- -- Set the clipboard provider to use the tmux functions
-- vim.g.clipboard = {
--   name = "tmux",
--   copy = {
--     ["+"] = copy_to_clipboard,
--     ["*"] = copy_to_clipboard,
--   },
--   paste = {
--     ["+"] = paste_from_clipboard,
--     ["*"] = paste_from_clipboard,
--   },
-- }
-- vim.g.clipboard = {
--   name = "tmux",
--   copy = {
--     ["+"] = "tmux load-buffer -",
--     ["*"] = "tmux load-buffer -",
--   },
--   paste = {
--     ["+"] = "tmux save-buffer -",
--     ["*"] = "tmux save-buffer -",
--   },
--   cache_enabled = true,
-- }

vim.g.clipboard = {
  name = "xsel",
  copy = {
    ["+"] = "xsel --clipboard --input",
    ["*"] = "xsel --primary --input",
  },
  paste = {
    ["+"] = "xsel --clipboard --output",
    ["*"] = "xsel --primary --output",
  },
  cache_enabled = true,
}
vim.o.clipboard = "unnamedplus"
-- vim.opt.clipboard:append("unnamedplus") -- use system clipboard

vim.opt.timeoutlen = 400 -- until which-key pops up
vim.opt.updatetime = 250 -- for autocommands and hovers

-- don't ask about existing swap files
vim.opt.shortmess:append("A")

-- mode is already in statusline
vim.opt.showmode = false

-- indentation
local tabsize = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = tabsize
vim.opt.tabstop = tabsize

-- space as leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- consistent number column
vim.opt.signcolumn = "yes:1"

-- how to show autocomplete menu
vim.opt.completeopt = "menuone,noinsert"

-- global statusline
vim.opt.laststatus = 3

vim.cmd([[
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
]])

math.randomseed(os.time())
local i = math.random(#animals)
vim.opt.statusline = "%{%g:currentmode[mode()]%} %{%reg_recording()%} %* %t | %y | %* %= c:%c l:%l/%L %p%% %#NonText# "
  .. animals[i]
  .. " %*"

-- hide cmdline when not used
vim.opt.cmdheight = 1

-- split right and below by default
vim.opt.splitright = true
vim.opt.splitbelow = true

--tabline
vim.opt.showtabline = 1

--windowline
vim.opt.winbar = "%f"

-- don't continue comments automagically
-- https://neovim.io/doc/user/options.html#'formatoptions'
vim.opt.formatoptions:remove("c")
vim.opt.formatoptions:remove("r")
vim.opt.formatoptions:remove("o")

-- scroll before end of window
vim.opt.scrolloff = 17

-- (don't == 0) replace certain elements with prettier ones
vim.opt.conceallevel = 0

-- diagnostics
vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  signs = true,
})

-- TODO: add Python, YAML, maybe others?
-- add new filetypes
vim.filetype.add({
  extension = {
    -- ojs = 'javascript',
  },
})

-- additional builtin vim packages
-- filter quickfix list with Cfilter
vim.cmd.packadd("cfilter")
