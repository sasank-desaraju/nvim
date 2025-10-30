local M = {}
local NS = vim.api.nvim_create_namespace("ProsePOS")

local POS_COLORS = {
  NOUN={group="ProsePOS_NOUN",hex="#FFD166"}, VERB={group="ProsePOS_VERB",hex="#EF476F"},
  ADJ={group="ProsePOS_ADJ",hex="#06D6A0"},   ADV={group="ProsePOS_ADV",hex="#3A86FF"},
  PRON={group="ProsePOS_PRON",hex="#FF7B00"}, DET={group="ProsePOS_DET",hex="#B56576"},
  ADP={group="ProsePOS_ADP",hex="#118AB2"},   CCONJ={group="ProsePOS_CCONJ",hex="#9B5DE5"},
  SCONJ={group="ProsePOS_SCONJ",hex="#9B5DE5"}, NUM={group="ProsePOS_NUM",hex="#00BBF9"},
  PART={group="ProsePOS_PART",hex="#2EC4B6"}, INTJ={group="ProsePOS_INTJ",hex="#F15BB5"},
  PUNCT={group="ProsePOS_PUNCT",hex="#FF3B30"}, SYM={group="ProsePOS_SYM",hex="#90A955"},
  AUX={group="ProsePOS_AUX",hex="#F77F00"},   PROPN={group="ProsePOS_PROPN",hex="#70E000"},
}

local function ensure_hlgroups()
  for _,v in pairs(POS_COLORS) do vim.api.nvim_set_hl(0,v.group,{bg=v.hex}) end
end

local function build_line_offsets(lines)
  local offs,acc={},0
  for i,s in ipairs(lines) do offs[i]=acc; acc=acc+#s+1 end
  return offs
end

local function charspan_to_lc(s0,e0,line_offs,lines)
  local function locate(pos)
    local lo,hi=1,#line_offs
    while lo<=hi do
      local mid=math.floor((lo+hi)/2)
      local start=line_offs[mid]
      local stop=start+#lines[mid]
      if mid<#line_offs then stop=stop+1 end
      if pos<start then hi=mid-1
      elseif pos>=stop then lo=mid+1
      else return mid-1,pos-start end
    end
    return #line_offs-1,0
  end
  local l1,c1=locate(s0); local l2,c2=locate(e0)
  return l1,c1,l2,c2
end

local function pos_spans_with_uv(text)
  local py = table.concat({
    "import sys, json",
    "import spacy",
    "nlp = spacy.load('en_core_web_sm', exclude=['ner','lemmatizer','textcat'])",
    "doc = nlp(sys.stdin.read())",
    "out = []",
    "for tok in doc:",
    "    pos = tok.pos_ or 'X'",
    "    out.append({'start': int(tok.idx), 'end': int(tok.idx+len(tok)), 'pos': pos})",
    "sys.stdout.write(json.dumps({'spans': out}))",
  },"\n")
  local out = vim.fn.system({
    "uv","run",
    "--with","spacy",
    "--with","en_core_web_sm @ https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.7.1/en_core_web_sm-3.7.1-py3-none-any.whl",
    "python","-c",py
  }, text)
  local ok,decoded=pcall(vim.json.decode,out)
  if not ok or type(decoded)~="table" then return nil,"bad Python output" end
  if decoded.error then return nil,decoded.error end
  return decoded.spans,nil
end

function M.clear() vim.api.nvim_buf_clear_namespace(0,NS,0,-1) end

function M.highlight()
  ensure_hlgroups(); M.clear()
  local lines = vim.api.nvim_buf_get_lines(0,0,-1,false)
  local text  = table.concat(lines,"\n")
  local line_offs = build_line_offsets(lines)
  local spans,err = pos_spans_with_uv(text)
  if not spans then vim.notify("ProsePOS: "..err, vim.log.levels.ERROR); return end
  for _,s in ipairs(spans) do
    local cfg=POS_COLORS[s.pos]
    if cfg then
      local l1,c1,l2,c2=charspan_to_lc(s.start,s.end,line_offs,lines)
      if l1==l2 then
        vim.api.nvim_buf_add_highlight(0,NS,cfg.group,l1,c1,c2)
      else
        vim.api.nvim_buf_add_highlight(0,NS,cfg.group,l1,c1,#lines[l1+1])
      end
    end
  end
end

vim.api.nvim_create_user_command("ProsePOSHighlight", function() M.highlight() end, {})
vim.api.nvim_create_user_command("ProsePOSClear",     function() M.clear()     end, {})
vim.api.nvim_create_autocmd("ColorScheme",{callback=ensure_hlgroups})

return M

