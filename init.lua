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
-- require 'prose_pos_highlight'

-- === Prose Nth Word Highlighter + Explicit Punctuation (BG only) ===

local M = {}

local NS_WORD  = vim.api.nvim_create_namespace("ProseNthHighlightWords")
local NS_PUNCT = vim.api.nvim_create_namespace("ProseNthHighlightPunct")

-- ----- CONFIG -----
-- Explicit palette (soft backgrounds recommended). Add/remove to taste.
-- Use accessible, moderate-contrast colors to avoid visual fatigue.
-- local PALETTE = {
--   "#FFF7AE", -- pale yellow
--   "#D8F5A2", -- light green
--   "#A5F3FC", -- light cyan
--   "#EBD3F8", -- light purple
--   "#FFD6D1", -- light coral
--   "#C7F0DB", -- mint
--   "#FDE68A", -- sand
-- }
-- rich color palette
-- local PALETTE = {
--   "#FFD166", -- warm amber
--   "#06D6A0", -- turquoise green
--   "#118AB2", -- deep teal blue
--   "#EF476F", -- vivid magenta-red
--   "#8338EC", -- rich purple
--   "#FF7B00", -- orange-gold
--   "#3A86FF", -- strong sky blue
-- }
-- desaturated studio palette
-- local PALETTE = {
--   "#E3B341", -- muted gold
--   "#4BBF81", -- sage green
--   "#4D96FF", -- denim blue
--   "#C14953", -- rose brick
--   "#9D6CD3", -- lavender
--   "#F57C00", -- tangerine
--   "#2EC4B6", -- seafoam teal
-- }
-- catpuccin
-- local PALETTE = {
--   "#f5e0dc",
--   "#f2cdcd",
--   "#f5c2e7",
--   "#cba6f7",
--   "#f38ba8",
--   "#eba0ac",
--   "#fab387",
--   "#f9e2af",
--   "#a6e3a1",
--   "#94e2d5",
--   "#89dceb",
--   "#74c7ec",
--   "#89b4fa",
--   "#b4befe"
-- }
local PALETTE = {
  "#b48ef7", "#e98ba5", "#e0a0a0", "#d45167",
  "#e88054", "#d9b754", "#76c45e", "#56b6a0",
  "#5fb3d1", "#4588c8", "#3f66d4", "#9a7fff",
  "#a24a63", "#6c7086"
}



-- Punctuation list (explicit). You can add/remove characters here.
-- Includes ASCII and some common Unicode punctuation.
local PUNCT_CHARS = {
  -- ".", ",", ";", ":", "!", "?", "/", "\\",
  ".", ";", ":", "!", "?",
  -- "-", "—", "–",  -- hyphen, em dash, en dash
  -- "(", ")", "[", "]", "{", "}",
  -- "\"", "'", "‘", "’", "“", "”",
  -- "…", "·", "•", "@", "#", "$", "%", "&", "*", "+", "=", "<", ">", "|", "^", "~", "`",
}

-- Background style for punctuation (no foreground set ⇒ text color unchanged)
local PUNCT_BG   = "#FF3B30"  -- iOS-style red; change if too strong for your theme
local PUNCT_BOLD = false
-- -------------------

local function ensure_hlgroups()
  -- Word highlight groups (background shades)
  for i, hex in ipairs(PALETTE) do
    local group = ("ProseNth_%d"):format(i)
    vim.api.nvim_set_hl(0, group, { bg = hex })
  end
  -- Punctuation background group (leave fg unset so text color stays the same)
  vim.api.nvim_set_hl(0, "ProseNth_PunctBG", { bg = PUNCT_BG, bold = PUNCT_BOLD })
end

function M.clear()
  vim.api.nvim_buf_clear_namespace(0, NS_WORD,  0, -1)
  vim.api.nvim_buf_clear_namespace(0, NS_PUNCT, 0, -1)
end

-- Escape Lua pattern magic for single-character literal searches.
local function escape_lua_magic(ch)
  -- Lua pattern magic chars: ( ) . % + - * ? [ ^ $ 
  if ch:match("[%(%)%.%%%+%-%*%?%[%^%$]") then
    return "%" .. ch
  end
  return ch
end

-- Highlight every Nth word and the explicit punctuation list.
function M.highlight(n)
  n = tonumber(n) or 3
  if n < 1 then
    vim.notify("ProseNthHighlight: N must be >= 1", vim.log.levels.WARN)
    return
  end

  ensure_hlgroups()
  M.clear()

  local buf = 0
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local word_idx = 0
  local palette_len = #PALETTE

  for lnum, line in ipairs(lines) do
    -- Pass 1: every Nth word (ASCII word chars; tweak pattern if you want hyphens/apostrophes inside words)
    local e = 1
    while true do
      local wstart, wend = string.find(line, "%w+", e)
      if not wstart then break end
      word_idx = word_idx + 1
      if (word_idx % n) == 0 then
        local color_idx = ((word_idx / n - 1) % palette_len) + 1
        local group = ("ProseNth_%d"):format(color_idx)
        vim.api.nvim_buf_add_highlight(buf, NS_WORD, group, lnum - 1, wstart - 1, wend)
      end
      e = wend + 1
    end

    -- Pass 2: explicit punctuation (background only). We search each character separately.
    -- To avoid double-highlighting the same byte position if two entries match, track seen indices.
    local seen = {}
    for _, ch in ipairs(PUNCT_CHARS) do
      local pat = "()" .. escape_lua_magic(ch)
      local pos = 1
      while true do
        local s = string.find(line, pat, pos)
        if not s then break end
        if not seen[s] then
          -- s is 1-based byte index of the char; end column is exclusive
          vim.api.nvim_buf_add_highlight(buf, NS_PUNCT, "ProseNth_PunctBG", lnum - 1, s - 1, s)
          seen[s] = true
        end
        pos = s + 1
      end
    end
  end
end

vim.api.nvim_create_user_command("ProseNthHighlight", function(opts)
  M.highlight(opts.args)
end, { nargs = "?", complete = function() return { "7" } end })

vim.api.nvim_create_user_command("ProseNthClear", function()
  M.clear()
end, {})

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = ensure_hlgroups,
})

return M

