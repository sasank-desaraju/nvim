-- required in which-key plugin spec in plugins/ui.lua as `require 'config.keymap'`
local wk = require 'which-key'

P = vim.print

vim.g['quarto_is_r_mode'] = nil
vim.g['reticulate_running'] = false

-- go to a tab by 'gi' for tab i
for i = 1, 9 do
  vim.keymap.set('n', 'g' .. i, function()
    vim.cmd(i .. 'tabnext')
  end, { desc = 'Go to tab ' .. i })
end

-- kj to exit insert mode
vim.keymap.set('i', 'kj', '<Esc>', { noremap = true, silent = true })

local nmap = function(key, effect)
  vim.keymap.set('n', key, effect, { silent = true, noremap = true })
end

local vmap = function(key, effect)
  vim.keymap.set('v', key, effect, { silent = true, noremap = true })
end

local imap = function(key, effect)
  vim.keymap.set('i', key, effect, { silent = true, noremap = true })
end

local cmap = function(key, effect)
  vim.keymap.set('c', key, effect, { silent = true, noremap = true })
end

-- TODO: This isn't quite working. I think it could be a tmux thing because <c-2> make the cursor take 2 presses of 'j' to move down one line
-- global mark shortcuts
vim.keymap.set('n', '<c-1>', 'mA') -- set a global mark with ctrl+1
vim.keymap.set('n', '<s-1>', 'A') -- go to a global mark with shift+1
vim.keymap.set('n', '<c-2>', 'mB')
vim.keymap.set('n', '<s-2>', 'B')
vim.keymap.set('n', '<c-3>', 'mC')
vim.keymap.set('n', '<s-3>', 'C')
vim.keymap.set('n', '<c-4>', 'mD')
vim.keymap.set('n', '<s-4>', 'D')

-- j and k within wrapped text blocks by default
nmap('j', 'gj')
nmap('k', 'gk')

-- move in command line
cmap('<C-a>', '<Home>')
cmap('<C-e>', '<End>')

-- save with ctrl+s
imap('<C-s>', '<esc>:update<cr><esc>')
nmap('<C-s>', '<cmd>:update<cr><esc>')

-- Move between windows using <ctrl> direction
nmap('<C-j>', '<C-W>j')
nmap('<C-k>', '<C-W>k')
nmap('<C-h>', '<C-W>h')
nmap('<C-l>', '<C-W>l')

-- Resize window using <shift> arrow keys
nmap('<S-Up>', '<cmd>resize +2<CR>')
nmap('<S-Down>', '<cmd>resize -2<CR>')
nmap('<S-Left>', '<cmd>vertical resize -2<CR>')
nmap('<S-Right>', '<cmd>vertical resize +2<CR>')

-- Add undo break-points
imap(',', ',<c-g>u')
imap('.', '.<c-g>u')
imap(';', ';<c-g>u')

-- What is this? Apparently, it just makes Q not map to anything. Q maps to some archaic "execute" mode or something.
nmap('Q', '<Nop>')

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
--- TODO: incorpoarate this into quarto-nvim plugin
--- such that QuartoRun functions get the same capabilities
--- TODO: figure out bracketed paste for reticulate python repl.
local function send_cell()
  if vim.b['quarto_is_r_mode'] == nil then
    vim.fn['slime#send_cell']()
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    end
    if not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end
    vim.fn['slime#send_cell']()
  end
end

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
-- local slime_send_region_cmd = ':<C-u>call slime#send_op(visualmode(), 1)<CR>'
-- slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)
-- local function send_region()
--   -- if filetyps is not quarto, just send_region
--   if vim.bo.filetype ~= 'quarto' or vim.b['quarto_is_r_mode'] == nil then
--     vim.cmd('normal' .. slime_send_region_cmd)
--     return
--   end
--   if vim.b['quarto_is_r_mode'] == true then
--     vim.g.slime_python_ipython = 0
--     local is_python = require('otter.tools.functions').is_otter_language_context 'python'
--     if is_python and not vim.b['reticulate_running'] then
--       vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
--       vim.b['reticulate_running'] = true
--     end
--     if not is_python and vim.b['reticulate_running'] then
--       vim.fn['slime#send']('exit' .. '\r')
--       vim.b['reticulate_running'] = false
--     end
--     vim.cmd('normal' .. slime_send_region_cmd)
--   end
-- end

-- send code with ctrl+Enter
-- just like in e.g. RStudio
-- needs kitty (or other terminal) config:
-- map shift+enter send_text all \x1b[13;2u
-- map ctrl+enter send_text all \x1b[13;5u
nmap('<c-cr>', send_cell)
nmap('<s-cr>', send_cell)
imap('<c-cr>', send_cell)
imap('<s-cr>', send_cell)

--- Show R dataframe in the browser
-- might not use what you think should be your default web browser
-- because it is a plain html file, not a link
-- see https://askubuntu.com/a/864698 for places to look for
local function show_r_table()
  local node = vim.treesitter.get_node { ignore_injections = false }
  assert(node, 'no symbol found under cursor')
  local text = vim.treesitter.get_node_text(node, 0)
  local cmd = [[call slime#send("DT::datatable(]] .. text .. [[)" . "\r")]]
  vim.cmd(cmd)
end

-- keep selection after indent/dedent
vmap('>', '>gv')
vmap('<', '<gv')

-- center after search and jumps
nmap('n', 'nzz')
nmap('<c-d>', '<c-d>zz')
nmap('<c-u>', '<c-u>zz')

-- move between splits and tabs
-- TODO: Get this working with Tmux
-- BUG: This is a repeat of lines 44
nmap('<c-h>', '<c-w>h')
nmap('<c-l>', '<c-w>l')
nmap('<c-j>', '<c-w>j')
nmap('<c-k>', '<c-w>k')
-- nmap('H', '<cmd>tabprevious<cr>')
-- nmap('L', '<cmd>tabnext<cr>')

local function toggle_light_dark_theme()
  if vim.o.background == 'light' then
    vim.o.background = 'dark'
  else
    vim.o.background = 'light'
  end
end

local is_code_chunk = function()
  local current, _ = require('otter.keeper').get_current_language_context()
  if current then
    return true
  else
    return false
  end
end

--- Insert code chunk of given language
--- Splits current chunk if already within a chunk
--- @param lang string
local insert_code_chunk = function(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
  local keys
  if is_code_chunk() then
    keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
  else
    keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
  end
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end

local insert_r_chunk = function()
  insert_code_chunk 'r'
end

local insert_py_chunk = function()
  insert_code_chunk 'python'
end

local insert_lua_chunk = function()
  insert_code_chunk 'lua'
end

local insert_julia_chunk = function()
  insert_code_chunk 'julia'
end

local insert_bash_chunk = function()
  insert_code_chunk 'bash'
end

local insert_ojs_chunk = function()
  insert_code_chunk 'ojs'
end

--show keybindings with whichkey
--add your own here if you want them to
--show up in the popup as well

-- normal mode
wk.add({
  { '<c-LeftMouse>', '<cmd>lua vim.lsp.buf.definition()<CR>', desc = 'go to definition' },
  { '<c-q>', '<cmd>q<cr>', desc = 'close buffer' },
  { '<esc>', '<cmd>noh<cr>', desc = 'remove search highlight' },
  { 'n', 'nzzzv', desc = 'center search' },
  { 'gN', 'Nzzzv', desc = 'center search' },
  { 'gl', '<c-]>', desc = 'open help link' },
  { 'gf', ':e <cfile><CR>', desc = 'edit file' },
  { '<m-i>', insert_r_chunk, desc = 'r code chunk' },
  { '<cm-i>', insert_py_chunk, desc = 'python code chunk' },
  { '<m-I>', insert_py_chunk, desc = 'python code chunk' },
  { ']q', ':silent cnext<cr>', desc = '[q]uickfix next' },
  { '[q', ':silent cprev<cr>', desc = '[q]uickfix prev' },
  { 'z?', ':setlocal spell!<cr>', desc = 'toggle [z]pellcheck' },
  { 'zl', ':Telescope spell_suggest<cr>', desc = '[l]ist spelling suggestions' },
}, { mode = 'n', silent = true })

-- visual mode
wk.add({
  { '<cr>', send_region, desc = 'run code region' },
  { '<M-j>', ":m'>+<cr>`<my`>mzgv`yo`z", desc = 'move line down' },
  { '<M-k>', ":m'<-2<cr>`>my`<mzgv`yo`z", desc = 'move line up' },
  { '.', ':norm .<cr>', desc = 'repeat last normal mode command' },
  { 'q', ':norm @q<cr>', desc = 'repeat q macro' },
  -- This interferes with using 'h' to move left when I'm selecting a block in visual mode, which I do quite frequently.
  -- h = {
  --   name = "[h]unk",
  --   s = {
  --     function()
  --       require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
  --     end,
  --     "hunk [s]tage",
  --   },
  --   r = {
  --     function()
  --       require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
  --     end,
  --     "hunk [r]eset",
  --   },
  -- },
}, { mode = 'v' })

-- visual with <leader>
wk.add({
  { '<leader>p', '"_dP', desc = 'replace without overwriting reg' },
  { '<leader>d', '"_d', desc = 'delete without overwriting reg' },
}, { mode = 'v' })

-- insert mode
wk.add({
  { '<m-->', ' <- ', desc = 'assign' },
  { '<m-m>', ' |>', desc = 'pipe' },
  { '<m-i>', insert_r_chunk, desc = 'r code chunk' },
  { '<cm-i>', insert_py_chunk, desc = 'python code chunk' },
  { '<m-I>', insert_py_chunk, desc = 'python code chunk' },
  { '<c-x><c-x>', '<c-x><c-o>', desc = 'omnifunc completion' },
}, { mode = 'i' })

local function new_terminal(lang)
  vim.cmd('vsplit term://' .. lang)
end

local function new_terminal_python()
  new_terminal 'python'
end

local function new_terminal_r()
  new_terminal 'R --no-save'
end

local function new_terminal_ipython()
  new_terminal 'ipython --no-confirm-exit'
end

local function new_terminal_julia()
  new_terminal 'julia'
end

local function new_terminal_shell()
  new_terminal '$SHELL'
end


-- Comments with Comment.nvim
wk.add({
    {
      '<leader>/',
      "<ESC><cmd>lua require('Comment.api').toggle.linewise()<CR>",
      mode = 'n',
      desc = 'Comment toggle current line',
    },
    {
      '<leader>/',
      "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
      mode = 'v',
      desc = 'Comment toggle linewise',
    },
})

-- normal mode with <leader>
wk.add({
  {
    -- { "<leader><cr>", send_cell, desc = "run code cell" },
    -- { "<leader>c", group = "[c]ode / [c]ell / [c]hunk" },
    -- { "<leader>ci", new_terminal_ipython, desc = "new [i]python terminal" },
    -- { "<leader>cj", new_terminal_julia, desc = "new [j]ulia terminal" },
    -- { "<leader>cn", new_terminal_shell, desc = "[n]ew terminal with shell" },
    -- { "<leader>cp", new_terminal_python, desc = "new [p]ython terminal" },
    -- { "<leader>cr", new_terminal_r, desc = "new [R] terminal" },

    { "<leader>c", group = "[c]laude code and friends" },
    { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Claude Code" },
    { "<leader>co", "<cmd>CodexToggle<cr>", desc = "Codex" },

    -- { "<leader>c", group = "[c]opilot chat" },
    -- { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "copilot [c]hat toggle" },
    -- { "<leader>cp", "<cmd>CopilotChatPrompts<cr>", desc = "copilot chat [p]rompts" },
    -- { "<leader>cm", "<cmd>CopilotChatModels<cr>", desc = "copilot chat [m]odels" },

    { "<leader>d", group = "[d]ebug" },
    { "<leader>dt", group = "[t]est" },
    { "<leader>e", group = "[e]dit" },
    { "<leader>f", group = "[f]ind (telescope)" },
    { "<leader>f<space>", "<cmd>Telescope buffers<cr>", desc = "[ ] buffers" },
    { "<leader>fM", "<cmd>Telescope man_pages<cr>", desc = "[M]an pages" },
    { "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "[b]uffer fuzzy find" },
    { "<leader>fc", "<cmd>Telescope git_commits<cr>", desc = "git [c]ommits" },
    { "<leader>fd", "<cmd>Telescope buffers<cr>", desc = "[d] buffers" },
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "[f]iles" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "[g]rep" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "[h]elp" },
    { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "[j]umplist" },
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "[k]eymaps" },
    { "<leader>fl", "<cmd>Telescope loclist<cr>", desc = "[l]oclist" },
    { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "[m]arks" },
    { "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "[q]uickfix" },
    { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "[r]eferences" },
    { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Find [o]ldfiles" },
    { "<leader>g", group = "[g]it" },
    { "<leader>gb", ":GitBlameToggle<cr>", desc = "[b]lame toggle virtual text" },
    -- { "<leader>gb", group = "[b]lame" },
    -- { "<leader>gbb", ":GitBlameToggle<cr>", desc = "[b]lame toggle virtual text" },
    -- { "<leader>gbc", ":GitBlameCopyCommitURL<cr>", desc = "[c]opy" },
    -- { "<leader>gbo", ":GitBlameOpenCommitURL<cr>", desc = "[o]pen" },
    { "<leader>gc", ":GitConflictRefresh<cr>", desc = "[c]onflict" },
    { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neo[g]it" },
    { "<leader>gl", "<cmd>LazyGit<cr>", desc = "[L]azyGit" },
    -- { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git [s]tatus" },
    { "<leader>gn", ":Gitsigns<cr>", desc = "Git sig[n]s" },
    { "<leader>gd", group = "[d]iff" },
    { "<leader>gdc", ":DiffviewClose<cr>", desc = "[c]lose" },
    { "<leader>gdo", ":DiffviewOpen<cr>", desc = "[o]pen" },
    { "<leader>gdf", ":DiffviewFileHistory<cr>", desc = "[f]ile history" },
    { "<leader>gdp", ":DiffviewFileHistory %<cr>", desc = "[p]resent file history" },
    { "<leader>gs", ":Gitsigns<cr>", desc = "git [s]igns" },
    { "<leader>gwc", ":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", desc = "worktree create" },
    { "<leader>gws", ":lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", desc = "worktree switch" },
    { "<leader>h", group = "[h]elp / [h]ide / [h]unk" },
    { "<leader>hs", ":Gitsigns stage_hunk<cr>", desc = "[s]tage hunk" },
    { "<leader>hr", ":Gitsigns reset_hunk<cr>", desc = "[r]eset hunk" },
    { "<leader>hp", ":Gitsigns preview_hunk<cr>", desc = "[p]review hunk" },
    { "<leader>hd", ":Gitsigns diffthis<cr>", desc = "start [d]iff for this file or so" }, -- TODO: compare Gitsigns diff vs Diffview.nvim one
    { "<leader>hc", group = "[c]onceal" },
    { "<leader>hch", ":set conceallevel=1<cr>", desc = "[h]ide/conceal" },
    { "<leader>hcs", ":set conceallevel=0<cr>", desc = "[s]how/unconceal" },
    { "<leader>ht", group = "[t]reesitter" },
    { "<leader>htt", vim.treesitter.inspect_tree, desc = "show [t]ree" },
    { "<leader>i", group = "[i]mage" },
    { "<leader>l", group = "[l]atex/language/lsp" },
    { "<leader>la", vim.lsp.buf.code_action, desc = "code [a]ction" },
    { "<leader>ll", ":VimtexCompile<cr>", desc = "Compile [l]atex" },
    { "<leader>ld", group = "[d]iagnostics" },
    { "<leader>ldd", function() vim.diagnostic.enable(false) end, desc = "[d]isable" },
    { "<leader>lde", vim.diagnostic.enable, desc = "[e]nable" },
    { "<leader>le", vim.diagnostic.open_float, desc = "diagnostics (show hover [e]rror)" },
    { "<leader>lg", ":Neogen<cr>", desc = "neo[g]en docstring" },
    -- { "<leader>o", group = "[o]tter & c[o]de" },
    -- { "<leader>oa", require'otter'.activate, desc = "otter [a]ctivate" },
    -- { "<leader>ob", insert_bash_chunk, desc = "[b]ash code chunk" },
    -- { "<leader>oc", "O# %%<cr>", desc = "magic [c]omment code chunk # %%" },
    -- { "<leader>od", require'otter'.activate, desc = "otter [d]eactivate" },
    -- { "<leader>oj", insert_julia_chunk, desc = "[j]ulia code chunk" },
    -- { "<leader>ol", insert_lua_chunk, desc = "[l]lua code chunk" },
    -- { "<leader>oo", insert_ojs_chunk, desc = "[o]bservable js code chunk" },
    -- { "<leader>op", insert_py_chunk, desc = "[p]ython code chunk" },
    -- { "<leader>or", insert_r_chunk, desc = "[r] code chunk" },
    { "<leader>o", group = "[o]bsidian" },
    { "<leader>od", ":ObsidianToday<cr>", desc = "obsidian [d]aily" },
    { "<leader>ot", ":ObsidianTemplate<cr>", desc = "obsidian [t]emplate" },
    { "<leader>oy", ":ObsidianToday -1<cr>", desc = "obsidian [y]esterday" },
    { "<leader>ob", ":ObsidianBacklinks<cr>", desc = "obsidian [b]acklinks" },
    { "<leader>ol", ":ObsidianLink<cr>", desc = "obsidian [l]ink selection" },
    { "<leader>of", ":ObsidianFollowLink<cr>", desc = "obsidian [f]ollow link" },
    { "<leader>on", ":ObsidianNew<cr>", desc = "obsidian [n]ew" },
    { "<leader>os", ":ObsidianSearch<cr>", desc = "obsidian [s]earch" },
    { "<leader>oo", ":ObsidianQuickSwitch<cr>", desc = "obsidian [o]pen quickswitch" },
    { "<leader>oO", ":ObsidianOpen<cr>", desc = "obsidian [O]pen in app" },
    -- { "<c-l>", ":ObsidianToggleCheckbox<cr>", desc = "Toggle checkbox" },
    { "<leader>q", group = "[q]uarto" },
    { "<leader>qp", ":lua require'quarto'.quartoPreview()<cr>", desc = "[p]review file" },
    { "<leader>qP", ":!quarto preview<cr>", desc = "[P]review project" },
    { "<leader>qr", ":!quarto render<cr>", desc = "[r]ender project" },
    { "<leader>qq", ":lua require'quarto'.quartoClosePreview()<cr>", desc = "[q]uit preview" },
    { "<leader>qh", ":QuartoHelp ", desc = "[h]elp" },
    -- { "<leader>r", group = "[r] R specific tools" },
    -- { "<leader>rt", show_r_table, desc = "show [t]able" },
    { "<leader>s", ":e $MYVIMRC | :cd %:p:h<cr>", desc = "[s]ettings" },
    { "<leader>t", new_terminal_shell, desc = "new [t]erminal with shell" },
    { "<leader>v", group = "[v]im" },
    { "<leader>vc", ":Telescope colorscheme<cr>", desc = "[c]olortheme" },
    { "<leader>vh", ':execute "h " . expand("<cword>")<cr>', desc = "vim [h]elp for current word" },
    { "<leader>vl", ":Lazy<cr>", desc = "[l]azy package manager" },
    { "<leader>vm", ":Mason<cr>", desc = "[m]ason software installer" },
    { "<leader>vs", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k<cr>", desc = "[s]ettings, edit vimrc" },
    { "<leader>vt", toggle_light_dark_theme, desc = "[t]oggle light/dark theme" },
    { "<leader>x", group = "e[x]ecute" },
    { "<leader>xx", ":w<cr>:source %<cr>", desc = "[x] source %" },
  }
}, { mode = 'n'})

-- Obsidian toggle checkbox
wk.add({
  { '<c-o>', ':ObsidianToggleCheckbox<cr>', desc = 'Toggle checkbox', mode = 'n' },
  { '<c-o>', ':ObsidianToggleCheckbox<cr>', desc = 'Toggle checkbox', mode = 'v' },
  { '<c-o>', '<esc>:ObsidianToggleCheckbox<cr>li', desc = 'Toggle checkbox', mode = 'i' },
})

-- Gp.nvim mappings
wk.add({
    -- VISUAL mode mappings
    -- s, x, v modes are handled the same way by which_key
    {
        mode = { "v" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", ":<C-u>'<,'>GpChatNew tabnew<cr>", desc = "ChatNew tabnew" },
        { "<C-g><C-v>", ":<C-u>'<,'>GpChatNew vsplit<cr>", desc = "ChatNew vsplit" },
        { "<C-g><C-x>", ":<C-u>'<,'>GpChatNew split<cr>", desc = "ChatNew split" },
        { "<C-g>a", ":<C-u>'<,'>GpAppend<cr>", desc = "Visual Append (after)" },
        { "<C-g>b", ":<C-u>'<,'>GpPrepend<cr>", desc = "Visual Prepend (before)" },
        { "<C-g>c", ":<C-u>'<,'>GpChatNew<cr>", desc = "Visual Chat New" },
        { "<C-g>g", group = "generate into new .." },
        { "<C-g>ge", ":<C-u>'<,'>GpEnew<cr>", desc = "Visual GpEnew" },
        { "<C-g>gn", ":<C-u>'<,'>GpNew<cr>", desc = "Visual GpNew" },
        { "<C-g>gp", ":<C-u>'<,'>GpPopup<cr>", desc = "Visual Popup" },
        { "<C-g>gt", ":<C-u>'<,'>GpTabnew<cr>", desc = "Visual GpTabnew" },
        { "<C-g>gv", ":<C-u>'<,'>GpVnew<cr>", desc = "Visual GpVnew" },
        { "<C-g>i", ":<C-u>'<,'>GpImplement<cr>", desc = "Implement selection" },
        { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
        { "<C-g>p", ":<C-u>'<,'>GpChatPaste<cr>", desc = "Visual Chat Paste" },
        { "<C-g>r", ":<C-u>'<,'>GpRewrite<cr>", desc = "Visual Rewrite" },
        { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
        { "<C-g>t", ":<C-u>'<,'>GpChatToggle<cr>", desc = "Visual Toggle Chat" },
        { "<C-g>w", group = "Whisper" },
        { "<C-g>wa", ":<C-u>'<,'>GpWhisperAppend<cr>", desc = "Whisper Append" },
        { "<C-g>wb", ":<C-u>'<,'>GpWhisperPrepend<cr>", desc = "Whisper Prepend" },
        { "<C-g>we", ":<C-u>'<,'>GpWhisperEnew<cr>", desc = "Whisper Enew" },
        { "<C-g>wn", ":<C-u>'<,'>GpWhisperNew<cr>", desc = "Whisper New" },
        { "<C-g>wp", ":<C-u>'<,'>GpWhisperPopup<cr>", desc = "Whisper Popup" },
        { "<C-g>wr", ":<C-u>'<,'>GpWhisperRewrite<cr>", desc = "Whisper Rewrite" },
        { "<C-g>wt", ":<C-u>'<,'>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
        { "<C-g>wv", ":<C-u>'<,'>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
        { "<C-g>ww", ":<C-u>'<,'>GpWhisper<cr>", desc = "Whisper" },
        { "<C-g>x", ":<C-u>'<,'>GpContext<cr>", desc = "Visual GpContext" },
    },

    -- NORMAL mode mappings
    {
        mode = { "n" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
        { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
        { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
        { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
        { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
        { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
        { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
        { "<C-g>g", group = "generate into new .." },
        { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
        { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
        { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
        { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
        { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
        { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
        { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
        { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
        { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
        { "<C-g>w", group = "Whisper" },
        { "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
        { "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
        { "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
        { "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
        { "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
        { "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
        { "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
        { "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
        { "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
        { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
    },

    -- INSERT mode mappings
    {
        mode = { "i" },
        nowait = true,
        remap = false,
        { "<C-g><C-t>", "<cmd>GpChatNew tabnew<cr>", desc = "New Chat tabnew" },
        { "<C-g><C-v>", "<cmd>GpChatNew vsplit<cr>", desc = "New Chat vsplit" },
        { "<C-g><C-x>", "<cmd>GpChatNew split<cr>", desc = "New Chat split" },
        { "<C-g>a", "<cmd>GpAppend<cr>", desc = "Append (after)" },
        { "<C-g>b", "<cmd>GpPrepend<cr>", desc = "Prepend (before)" },
        { "<C-g>c", "<cmd>GpChatNew<cr>", desc = "New Chat" },
        { "<C-g>f", "<cmd>GpChatFinder<cr>", desc = "Chat Finder" },
        { "<C-g>g", group = "generate into new .." },
        { "<C-g>ge", "<cmd>GpEnew<cr>", desc = "GpEnew" },
        { "<C-g>gn", "<cmd>GpNew<cr>", desc = "GpNew" },
        { "<C-g>gp", "<cmd>GpPopup<cr>", desc = "Popup" },
        { "<C-g>gt", "<cmd>GpTabnew<cr>", desc = "GpTabnew" },
        { "<C-g>gv", "<cmd>GpVnew<cr>", desc = "GpVnew" },
        { "<C-g>n", "<cmd>GpNextAgent<cr>", desc = "Next Agent" },
        { "<C-g>r", "<cmd>GpRewrite<cr>", desc = "Inline Rewrite" },
        { "<C-g>s", "<cmd>GpStop<cr>", desc = "GpStop" },
        { "<C-g>t", "<cmd>GpChatToggle<cr>", desc = "Toggle Chat" },
        { "<C-g>w", group = "Whisper" },
        { "<C-g>wa", "<cmd>GpWhisperAppend<cr>", desc = "Whisper Append (after)" },
        { "<C-g>wb", "<cmd>GpWhisperPrepend<cr>", desc = "Whisper Prepend (before)" },
        { "<C-g>we", "<cmd>GpWhisperEnew<cr>", desc = "Whisper Enew" },
        { "<C-g>wn", "<cmd>GpWhisperNew<cr>", desc = "Whisper New" },
        { "<C-g>wp", "<cmd>GpWhisperPopup<cr>", desc = "Whisper Popup" },
        { "<C-g>wr", "<cmd>GpWhisperRewrite<cr>", desc = "Whisper Inline Rewrite" },
        { "<C-g>wt", "<cmd>GpWhisperTabnew<cr>", desc = "Whisper Tabnew" },
        { "<C-g>wv", "<cmd>GpWhisperVnew<cr>", desc = "Whisper Vnew" },
        { "<C-g>ww", "<cmd>GpWhisper<cr>", desc = "Whisper" },
        { "<C-g>x", "<cmd>GpContext<cr>", desc = "Toggle GpContext" },
        { "<S-Tab>", 'copilot#Accept("\\<S-Tab>")', desc = "Toggle GpContext", expr = true, replace_keycodes = false }, -- stops Copilot's tab completion according to CopilotChat.nvim
    },
})
