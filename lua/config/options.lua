-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = false

-- LazyVim v16 picks ONE completion engine and hard-disables the rest.
-- Its own config/options.lua sets this to "auto", which resolves to blink.cmp
-- and orphans nvim-cmp (breaking completion.lua, lsp.lua's cmp_nvim_lsp,
-- notes.lua/obsidian and copilot-cmp). This file is loaded after LazyVim's,
-- so it must be set here -- setting it in config/global.lua gets clobbered.
vim.g.lazyvim_cmp = "nvim-cmp"

-- Same mechanism for the picker. "auto" resolves to snacks, whose
-- editor/snacks_picker.lua ships an alpha-nvim override expecting alpha's
-- dashboard table as `opts`. welcome-screen.lua builds it inside `config`,
-- so that override gets an empty table and `dashboard.button` is nil.
-- This config uses telescope everywhere anyway.
vim.g.lazyvim_picker = "telescope"
