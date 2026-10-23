local function set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  pattern = { '*' },
  command = 'checktime',
})

vim.api.nvim_create_autocmd({ 'TermOpen' }, {
  pattern = { '*' },
  callback = function(_)
    vim.cmd.setlocal 'nonumber'
    vim.wo.signcolumn = 'no'
    set_terminal_keymaps()
  end,
})

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.bo.omnifunc = "vimtex#complete#omnifunc"
  end,
})

-- Auto-save and restore folds when leaving/entering a buffer
vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
  pattern = "*",
  command = "silent! mkview"
})
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  pattern = "*",
  command = "silent! loadview"
})


-- Auto-activate a project's .venv (nearest parent dir containing .venv/bin/python).
-- Sets VIRTUAL_ENV, QUARTO_PYTHON and PATH for Neovim and everything it launches
-- (quarto preview/render, slime terminals, LSPs). No .venv => original env.
do
  local base_path = vim.env.PATH
  local active
  local function sync(buf)
    if vim.bo[buf].buftype ~= "" then return end
    local root = vim.fs.root(buf, function(name, path)
      return name == ".venv" and vim.uv.fs_stat(path .. "/.venv/bin/python") ~= nil
    end)
    local venv = root and (root .. "/.venv") or nil
    if venv == active then return end
    active = venv
    if venv then
      vim.env.VIRTUAL_ENV = venv
      vim.env.QUARTO_PYTHON = venv .. "/bin/python"
      vim.env.PATH = venv .. "/bin:" .. base_path
    else
      vim.env.VIRTUAL_ENV, vim.env.QUARTO_PYTHON, vim.env.PATH = nil, nil, base_path
    end
  end
  vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, {
    group = vim.api.nvim_create_augroup("auto-venv", { clear = true }),
    callback = function(ev) sync(ev.buf) end,
  })
end
