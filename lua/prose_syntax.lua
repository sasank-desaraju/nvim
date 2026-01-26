local M = {}
-- Use a distinct namespace for this plugin
local NS = vim.api.nvim_create_namespace("ProseSyntax")

-- Define colors based on grammatical role
-- User request: Nouns = Red, Verbs = Blue
local POS_COLORS = {
  NOUN  = { group = "ProseSyntax_NOUN",  hex = "#FF3B30" }, -- Red
  VERB  = { group = "ProseSyntax_VERB",  hex = "#3A86FF" }, -- Blue
  
  -- Supplementary colors
  ADJ   = { group = "ProseSyntax_ADJ",   hex = "#06D6A0" }, -- Green
  ADV   = { group = "ProseSyntax_ADV",   hex = "#FFD166" }, -- Yellow
  PRON  = { group = "ProseSyntax_PRON",  hex = "#FF7B00" }, -- Orange
  DET   = { group = "ProseSyntax_DET",   hex = "#B56576" }, -- Rose
  ADP   = { group = "ProseSyntax_ADP",   hex = "#118AB2" }, -- Teal
  NUM   = { group = "ProseSyntax_NUM",   hex = "#00BBF9" }, -- Light Blue
  CONJ  = { group = "ProseSyntax_CONJ",  hex = "#9B5DE5" }, -- Purple
  CCONJ = { group = "ProseSyntax_CCONJ", hex = "#9B5DE5" }, -- Purple
  SCONJ = { group = "ProseSyntax_SCONJ", hex = "#9B5DE5" }, -- Purple
  PART  = { group = "ProseSyntax_PART",  hex = "#2EC4B6" }, -- Cyan
  INTJ  = { group = "ProseSyntax_INTJ",  hex = "#F15BB5" }, -- Pink
  PROPN = { group = "ProseSyntax_PROPN", hex = "#8338EC" }, -- Violet (Proper Noun)
  AUX   = { group = "ProseSyntax_AUX",   hex = "#3A86FF" }, -- Blue (Auxiliary Verb, same as Verb)
  
  -- Less emphasized
  PUNCT = { group = "ProseSyntax_PUNCT", hex = "#555555" }, -- Grey
  SYM   = { group = "ProseSyntax_SYM",   hex = "#90A955" }, -- Sage
  X     = { group = "ProseSyntax_X",     hex = "#999999" }, -- Unknown
}

local function ensure_hlgroups()
  for _, v in pairs(POS_COLORS) do
    vim.api.nvim_set_hl(0, v.group, { fg = v.hex }) -- Using fg instead of bg for syntax highlighting usually looks better, but can swap to bg if desired
  end
end

-- Efficiently map byte offsets to (line, col)
local function build_line_offsets(lines)
  local offs, acc = {}, 0
  for i, s in ipairs(lines) do
    offs[i] = acc
    acc = acc + #s + 1 -- +1 for newline
  end
  return offs
end

local function charspan_to_lc(s0, e0, line_offs, lines)
  local function locate(pos)
    local lo, hi = 1, #line_offs
    while lo <= hi do
      local mid = math.floor((lo + hi) / 2)
      local start = line_offs[mid]
      local stop = start + #lines[mid]
      if mid < #line_offs then stop = stop + 1 end
      
      if pos < start then
        hi = mid - 1
      elseif pos >= stop then
        lo = mid + 1
      else
        return mid - 1, pos - start
      end
    end
    return #line_offs - 1, 0
  end
  
  local l1, c1 = locate(s0)
  local l2, c2 = locate(e0)
  return l1, c1, l2, c2
end

local function pos_spans_with_uv(text)
  -- Python script to run via uv
  local py = table.concat({
    "import sys, json",
    "try:",
    "    import spacy",
    "except ImportError:",
    "    sys.stdout.write(json.dumps({'error': 'spacy not installed'}))",
    "    sys.exit(1)",
    "",
    "try:",
    "    nlp = spacy.load('en_core_web_sm', exclude=['ner', 'lemmatizer', 'textcat'])",
    "except OSError:",
    "    sys.stdout.write(json.dumps({'error': 'model en_core_web_sm not found'}))",
    "    sys.exit(1)",
    "",
    "doc = nlp(sys.stdin.read())",
    "out = []",
    "for tok in doc:",
    "    pos = tok.pos_ or 'X'",
    "    out.append({'start': int(tok.idx), 'end': int(tok.idx + len(tok)), 'pos': pos})",
    "sys.stdout.write(json.dumps({'spans': out}))",
  }, "\n")

  -- Use uv to run the script in an ephemeral environment with spacy and the model installed
  -- We unset PYTHONPATH to avoid conflicts with system packages (e.g. typer)
  local out = vim.fn.system({
    "env", "PYTHONPATH=",
    "uv", "run",
    "--with", "spacy",
    "--with", "en_core_web_sm @ https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.7.1/en_core_web_sm-3.7.1-py3-none-any.whl",
    "python", "-c", py
  }, text)

  local ok, decoded = pcall(vim.json.decode, out)
  if not ok or type(decoded) ~= "table" then
    return nil, "Bad Python output: " .. (out or "nil")
  end
  if decoded.error then
    return nil, decoded.error
  end
  return decoded.spans, nil
end

function M.clear()
  vim.api.nvim_buf_clear_namespace(0, NS, 0, -1)
end

function M.highlight()
  ensure_hlgroups()
  M.clear()
  
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local text = table.concat(lines, "\n")
  
  -- Don't run on empty buffers
  if #text == 0 then return end
  
  vim.notify("ProseSyntax: Analyzing...", vim.log.levels.INFO)
  
  -- Run async to avoid freezing UI? 
  -- Current implementation is sync (vim.fn.system) which blocks. 
  -- For a prototype, this is acceptable, but for large files it will pause editor.
  local line_offs = build_line_offsets(lines)
  local spans, err = pos_spans_with_uv(text)
  
  if not spans then
    vim.notify("ProseSyntax Error: " .. tostring(err), vim.log.levels.ERROR)
    return
  end
  
  for _, s in ipairs(spans) do
    local cfg = POS_COLORS[s.pos]
    if cfg then
      local l1, c1, l2, c2 = charspan_to_lc(s.start, s["end"], line_offs, lines)
      
      -- Ensure we don't go out of bounds
      if lines[l1 + 1] then
        if l1 == l2 then
          vim.api.nvim_buf_add_highlight(0, NS, cfg.group, l1, c1, c2)
        else
          -- Multiline token (rare for words, but possible)
          vim.api.nvim_buf_add_highlight(0, NS, cfg.group, l1, c1, #lines[l1 + 1])
        end
      end
    end
  end
  
  vim.notify("ProseSyntax: Done.", vim.log.levels.INFO)
end

-- Commands
vim.api.nvim_create_user_command("ProseSyntaxHighlight", function() M.highlight() end, {})
vim.api.nvim_create_user_command("ProseSyntaxClear",     function() M.clear()     end, {})

-- Autocmd to ensure colors are set after scheme changes
vim.api.nvim_create_autocmd("ColorScheme", { callback = ensure_hlgroups })

return M
