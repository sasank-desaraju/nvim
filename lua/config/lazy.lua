--  bootstrap lazy package manager
--  <https://github.com/folke/lazy.nvim>
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

-- actually load Lazy
require("lazy").setup("plugins", {
  defaults = {
    version = false,
  },
  -- TODO: What is this. Maybe it'll be useful...
  dev = {
    path = "~/projects",
    fallback = true,
  },
  install = {
    missing = true,
    colorscheme = { "default" },
  },
  checker = { enabled = false },
  rtp = {
    disabled_plugins = {
      "gzip",
      "matchit",
      "matchparen",
      "netrwPlugin",
      "tarPlugin",
      "tohtml",
      "tutor",
      "zipPlugin",
    },
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
})
