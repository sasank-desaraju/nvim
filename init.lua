-- NOTE: Throughout this config, some plugins are
-- disabled by default. This is because I don't use
-- them on a daily basis, but I still want to keep
-- them around as examples.
-- You can enable them by changing `enabled = false`
-- to `enabled = true` in the respective plugin spec.
-- Some of these also have the
-- PERF: (performance) comment, which
-- indicates that I found them to slow down the config.
-- (may be outdated with newer versions of the plugins,
-- check for yourself if you're interested in using them)

_G.env = require('config.env')
require 'config.global'
require 'config.lazy'
require 'config.autocommands'

-- Prose Tools (Uncomment to enable if they are working)
require 'prose_nth_highlight'
require 'prose_syntax'

-- :ProseReload re-sources the prose modules without restarting nvim
vim.api.nvim_create_user_command("ProseReload", function()
  for _, m in ipairs({ "prose_nth_highlight", "prose_syntax" }) do
    package.loaded[m] = nil
    require(m)
  end
  vim.notify("Prose modules reloaded")
end, {})
