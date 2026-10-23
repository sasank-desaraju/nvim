-- LazyVim (2026) manages nvim-treesitter on the `main` branch: it installs
-- `ensure_installed` parsers and turns on highlight/indent/folds itself.
-- We only extend its parser list here; overriding `config` (old master API)
-- silently disabled all of that.
return {
  {
    'nvim-treesitter/nvim-treesitter',
    opts = {
      ensure_installed = {
        'r', 'python', 'markdown', 'markdown_inline', 'julia', 'bash', 'yaml',
        'lua', 'vim', 'query', 'vimdoc', 'latex', 'html', 'css', 'dot',
        'javascript', 'mermaid', 'typescript',
      },
    },
  },
}
