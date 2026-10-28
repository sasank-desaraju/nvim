-- Inline images (PNG figures etc.) in markdown/quarto via snacks.nvim's image module.
-- Needs a Kitty-graphics terminal (Ghostty/Kitty/WezTerm); works over ssh. `magick` for non-PNG.
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      image = {
        enabled = true,
        doc = {
          enabled = true,
          inline = true, -- render images below their ![](...) link
          float = true,  -- if inline isn't possible, show on cursor hover
          max_width = 80,
          max_height = 30,
        },
      },
    },
  },
}
