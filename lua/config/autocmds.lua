-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

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
