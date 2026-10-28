-- === Quarto overlay: darker Python code + inline number preview ===
-- :QmdCodeShade        toggle darker background on ```{python}``` chunks and `{python} ...` spans
-- :QmdNumbers          toggle (per buffer) virtual text with the value of each inline `{python} expr`
-- :QmdNumbersConceal   toggle (per buffer) hiding the inline code so only the value shows

local M = {}

local NS_SHADE = vim.api.nvim_create_namespace("QmdCodeShade")
local NS_NUM   = vim.api.nvim_create_namespace("QmdNumbers")

-- ----- CONFIG -----
local DARKEN        = 0.78        -- multiply Normal bg channels by this (~22% darker)
local FALLBACK_BG   = "#16161e"   -- used when Normal has no bg (transparent themes)
local SHADE_PRIO    = 10          -- low, so prose highlighters (default 4096) draw on top
local CODE_FG       = "#8a8a8a"   -- grey text for code, overriding treesitter colors
local CODE_FG_PRIO  = 200         -- above treesitter (100)
local DEBOUNCE_MS   = 200
local HELPER_TIMEOUT_MS = 180000
local SCRIPT = vim.fn.stdpath("config") .. "/scripts/qmd_inline_eval.py"
local FILETYPES = { quarto = true, markdown = true }

M.shade_enabled = true
M.state = {} -- [bufnr] = { numbers, conceal, running, items, chunk_errors, elapsed, conceallevel }

local function is_qmd(buf)
  return vim.api.nvim_buf_is_valid(buf) and FILETYPES[vim.bo[buf].filetype] == true
end

-- ----- colors -----
local function darken(rgb, f)
  local r = math.floor(bit.rshift(rgb, 16) % 256 * f)
  local g = math.floor(bit.rshift(rgb, 8) % 256 * f)
  local b = math.floor(rgb % 256 * f)
  return string.format("#%02x%02x%02x", r, g, b)
end

local function ensure_hlgroups()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local bg = normal.bg and darken(normal.bg, DARKEN) or FALLBACK_BG
  vim.api.nvim_set_hl(0, "QmdCodeShade", { bg = bg })
  vim.api.nvim_set_hl(0, "QmdCodeFg", { fg = CODE_FG })
  vim.api.nvim_set_hl(0, "QmdNumberValue", { link = "Comment", default = true })
  vim.api.nvim_set_hl(0, "QmdNumberError", { link = "DiagnosticError", default = true })
end

-- ----- feature 1: code shade -----
function M.shade(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.api.nvim_buf_clear_namespace(buf, NS_SHADE, 0, -1)
  if not M.shade_enabled or not is_qmd(buf) then return end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local in_chunk = false
  for i, l in ipairs(lines) do
    local row = i - 1
    if not in_chunk and l:match("^%s*```+%s*{python") then
      in_chunk = true
    end
    if in_chunk then
      vim.api.nvim_buf_set_extmark(buf, NS_SHADE, row, 0,
        { line_hl_group = "QmdCodeShade", priority = SHADE_PRIO })
      if #l > 0 then
        vim.api.nvim_buf_set_extmark(buf, NS_SHADE, row, 0,
          { end_col = #l, hl_group = "QmdCodeFg", priority = CODE_FG_PRIO })
      end
      if l:match("^%s*```+%s*$") then in_chunk = false end
    else
      local init = 1
      while true do
        local s, e = l:find("`{python}[^`]*`", init)
        if not s then break end
        vim.api.nvim_buf_set_extmark(buf, NS_SHADE, row, s - 1,
          { end_col = e, hl_group = "QmdCodeShade", priority = SHADE_PRIO })
        vim.api.nvim_buf_set_extmark(buf, NS_SHADE, row, s - 1,
          { end_col = e, hl_group = "QmdCodeFg", priority = CODE_FG_PRIO })
        init = e + 1
      end
    end
  end
end

local timers = {}
local function shade_debounced(buf)
  local t = timers[buf]
  if not t then
    t = vim.uv.new_timer()
    timers[buf] = t
  end
  t:stop()
  t:start(DEBOUNCE_MS, 0, vim.schedule_wrap(function() M.shade(buf) end))
end

function M.toggle_shade()
  M.shade_enabled = not M.shade_enabled
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then M.shade(b) end
  end
  vim.notify("QmdCodeShade " .. (M.shade_enabled and "on" or "off"))
end

-- ----- feature 2: number overlay -----
local function find_python(file)
  for dir in vim.fs.parents(file) do
    local p = dir .. "/.venv/bin/python"
    if vim.fn.executable(p) == 1 then return p end
  end
  return "python3"
end

local function wins_for(buf)
  return vim.tbl_filter(function(w) return vim.api.nvim_win_get_buf(w) == buf end,
    vim.api.nvim_list_wins())
end

local function set_conceal_level(buf, on)
  local st = M.state[buf]
  for _, w in ipairs(wins_for(buf)) do
    if on then
      st.conceallevel = st.conceallevel or vim.wo[w].conceallevel
      if vim.wo[w].conceallevel < 2 then vim.wo[w].conceallevel = 2 end
    elseif st.conceallevel then
      vim.wo[w].conceallevel = st.conceallevel
    end
  end
  if not on then st.conceallevel = nil end
end

local inline_ok = vim.fn.has("nvim-0.10") == 1

function M.render(buf)
  local st = M.state[buf]
  vim.api.nvim_buf_clear_namespace(buf, NS_NUM, 0, -1)
  if not st or not st.numbers or not st.items then return end
  local nlines = vim.api.nvim_buf_line_count(buf)
  for _, it in ipairs(st.items) do
    if it.line < nlines then
      local conceal = st.conceal and it.value ~= nil
      local text, hl
      if it.value ~= nil then
        text, hl = (conceal and "" or " ") .. it.value, "QmdNumberValue"
      else
        local msg = tostring(it.error or "error"):gsub("\n.*", "")
        if #msg > 60 then msg = msg:sub(1, 57) .. "..." end
        text, hl = " ⚠ " .. msg, "QmdNumberError"
      end
      pcall(vim.api.nvim_buf_set_extmark, buf, NS_NUM, it.line, it.col_end, {
        virt_text = { { text, hl } },
        virt_text_pos = inline_ok and "inline" or "eol",
        hl_mode = "combine",
      })
      if conceal then
        pcall(vim.api.nvim_buf_set_extmark, buf, NS_NUM, it.line, it.col_start,
          { end_col = it.col_end, conceal = "" })
      end
    end
  end
end

function M.run_numbers(buf)
  buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
  local st = M.state[buf]
  if not st or not st.numbers then return end
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" or vim.fn.filereadable(file) == 0 then
    vim.notify("QmdNumbers: buffer has no file on disk", vim.log.levels.WARN)
    return
  end
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  st.running = true
  local py = find_python(file)
  vim.system({ py, SCRIPT, file }, { text = true, timeout = HELPER_TIMEOUT_MS,
      cwd = vim.fs.dirname(file) }, vim.schedule_wrap(function(res)
    st.running = false
    if not vim.api.nvim_buf_is_valid(buf) or not st.numbers then return end
    if res.code ~= 0 then
      local why = res.signal == 15 and "timed out" or ((res.stderr or ""):sub(-300))
      vim.notify("QmdNumbers: helper failed (" .. res.code .. "): " .. why, vim.log.levels.ERROR)
      return
    end
    local ok, decoded = pcall(vim.json.decode, res.stdout or "")
    if not ok or type(decoded) ~= "table" then
      vim.notify("QmdNumbers: bad JSON from helper", vim.log.levels.ERROR)
      return
    end
    if vim.api.nvim_buf_get_changedtick(buf) ~= tick then
      vim.notify("QmdNumbers: buffer changed during evaluation, skipping update.", vim.log.levels.WARN)
      return
    end
    st.items = decoded.items or {}
    st.chunk_errors = decoded.chunk_errors or {}
    st.elapsed = decoded.elapsed
    M.render(buf)
    local nerr = 0
    for _, it in ipairs(st.items) do if it.value == nil then nerr = nerr + 1 end end
    vim.notify(string.format("QmdNumbers: %d values, %d errors, %d chunk errors (%.1fs)",
      #st.items - nerr, nerr, #st.chunk_errors, decoded.elapsed or 0))
  end))
end

function M.toggle_numbers()
  local buf = vim.api.nvim_get_current_buf()
  if not is_qmd(buf) then
    vim.notify("QmdNumbers: not a quarto/markdown buffer", vim.log.levels.WARN)
    return
  end
  local st = M.state[buf] or {}
  M.state[buf] = st
  st.numbers = not st.numbers
  local gname = "QmdNumbers_" .. buf
  if st.numbers then
    local grp = vim.api.nvim_create_augroup(gname, { clear = true })
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = grp, buffer = buf,
      callback = function() M.run_numbers(buf) end,
      desc = "Rerun QmdNumbers on save",
    })
    vim.notify("QmdNumbers: evaluating (async)...")
    M.run_numbers(buf)
  else
    pcall(vim.api.nvim_del_augroup_by_name, gname)
    if st.conceal then set_conceal_level(buf, false) end
    M.state[buf] = nil
    vim.api.nvim_buf_clear_namespace(buf, NS_NUM, 0, -1)
    vim.notify("QmdNumbers off")
  end
end

function M.toggle_conceal()
  local buf = vim.api.nvim_get_current_buf()
  local st = M.state[buf]
  if not st or not st.numbers then
    vim.notify("QmdNumbersConceal: turn on :QmdNumbers first", vim.log.levels.WARN)
    return
  end
  st.conceal = not st.conceal
  set_conceal_level(buf, st.conceal)
  M.render(buf)
end

-- ----- wiring -----
ensure_hlgroups()
local grp = vim.api.nvim_create_augroup("QmdOverlay", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = grp,
  callback = function()
    ensure_hlgroups()
  end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
  group = grp, pattern = "*.qmd",
  callback = function(ev) M.shade(ev.buf) end,
})
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  group = grp, pattern = "*.qmd",
  callback = function(ev) shade_debounced(ev.buf) end,
})
vim.api.nvim_create_autocmd("BufWipeout", {
  group = grp, pattern = "*.qmd",
  callback = function(ev)
    M.state[ev.buf] = nil
    if timers[ev.buf] then timers[ev.buf]:close(); timers[ev.buf] = nil end
  end,
})

vim.api.nvim_create_user_command("QmdCodeShade", M.toggle_shade, {})
vim.api.nvim_create_user_command("QmdNumbers", M.toggle_numbers, {})
vim.api.nvim_create_user_command("QmdNumbersConceal", M.toggle_conceal, {})

return M
