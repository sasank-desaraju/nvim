return {
  {

    -- for lsp features in code cells / embedded code
    "jmbuhr/otter.nvim",
    enabled = false,
    dev = false,
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
      },
    },
    opts = {
      lsp = {
        hover = {
          border = require("misc.style").border,
        },
      },
      buffers = {
        set_filetype = true,
        write_to_disk = false,
      },
      handle_leading_whitespace = true,
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      { -- nice loading notifications
        -- PERF: but can slow down startup
        "j-hui/fidget.nvim",
        enabled = false,
        opts = {},
      },
      { "folke/neodev.nvim", opts = {}, enabled = true },
      { "folke/neoconf.nvim", opts = {}, enabled = false },
    },
    config = function()
      local lspconfig = require("lspconfig")
      local util = require("lspconfig.util")
      local has_native_lsp_config = vim.fn.has("nvim-0.11") == 1 and vim.lsp.config ~= nil and vim.lsp.enable ~= nil

      local function setup_server(name, config)
        if has_native_lsp_config then
          vim.lsp.config(name, config)
          vim.lsp.enable(name)
          return
        end

        lspconfig[name].setup(config)
      end

      local mason_tools = {
        "pyright",
        "tree-sitter-cli",
        "jupytext",
      }

      -- Initialize Mason at startup so :Mason is an exact command and its
      -- package binaries are available to LSP clients.
      require("mason").setup({ PATH = "prepend" })
      require("mason-lspconfig").setup()
      require("mason-tool-installer").setup({
        ensure_installed = mason_tools,
      })

      vim.api.nvim_create_user_command('MasonBootstrap', function()
        require("mason").setup({ PATH = "prepend" })
        require("mason-lspconfig").setup()
        require("mason-tool-installer").setup({
          ensure_installed = mason_tools,
        })
        vim.cmd("MasonToolsInstall")
      end, { desc = 'Install configured Mason tools' })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local telescope = require("telescope.builtin")
          local function map(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          assert(client, "LSP client not found")

          ---@diagnostic disable-next-line: inject-field
          client.server_capabilities.document_formatting = true

          map("gS", telescope.lsp_document_symbols, "[g]o so [S]ymbols")
          map("gD", telescope.lsp_type_definitions, "[g]o to type [D]efinition")
          map("gd", telescope.lsp_definitions, "[g]o to [d]efinition")
          map("K", "<cmd>lua vim.lsp.buf.hover()<CR>", "[K] hover documentation")
          map("gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", "[g]o to signature [h]elp")
          map("gI", telescope.lsp_implementations, "[g]o to [I]mplementation")
          map("gr", telescope.lsp_references, "[g]o to [r]eferences")
          map("[d", vim.diagnostic.goto_prev, "previous [d]iagnostic ")
          map("]d", vim.diagnostic.goto_next, "next [d]iagnostic ")
          -- map("<leader>ll", vim.lsp.codelens.run, "[l]ens run")
          map("<leader>lR", vim.lsp.buf.rename, "[l]sp [R]ename")
          map("<leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, "[l]sp [f]ormat (manual)")
          map("<leader>lq", vim.diagnostic.setqflist, "[l]sp diagnostic [q]uickfix")
        end,
      })

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }
      vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        config = vim.tbl_deep_extend("force", config or {}, { border = require("misc.style").border })
        return vim.lsp.handlers.hover(err, result, ctx, config)
      end
      vim.lsp.handlers["textDocument/signatureHelp"] = function(err, result, ctx, config)
        config = vim.tbl_deep_extend("force", config or {}, { border = require("misc.style").border })
        return vim.lsp.handlers.signature_help(err, result, ctx, config)
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- also needs:
      -- $home/.config/marksman/config.toml :
      -- [core]
      -- markdown.file_extensions = ["md", "markdown", "qmd"]
      setup_server('marksman', {
        capabilities = capabilities,
        -- filetypes = { "markdown" },
        root_dir = util.root_pattern(".git", ".marksman.toml"),
        single_file_support = true,
      })

      -- lspconfig.r_language_server.setup({
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      --   settings = {
      --     r = {
      --       lsp = {
      --         rich_documentation = false,
      --       },
      --     },
      --   },
      -- })

      -- lspconfig.cssls.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- }
      --
      -- lspconfig.html.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- }
      --
      -- lspconfig.emmet_language_server.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- }

      -- TODO: Get YAML LS working
      -- lspconfig.yamlls.setup({
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      --   settings = {
      --     yaml = {
      --       schemaStore = {
      --         enable = true,
      --         url = "",
      --       },
      --     },
      --   },
      -- })

      -- lspconfig.dotls.setup({
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- })
      --
      -- lspconfig.tsserver.setup({
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      --   filetypes = { "js", "javascript", "typescript", "ojs" },
      -- })

      -- TODO: Fix Quarto
      -- local function get_quarto_resource_path()
      --   local function strsplit(s, delimiter)
      --     local result = {}
      --     for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
      --       table.insert(result, match)
      --     end
      --     return result
      --   end
      --
      --   local f = assert(io.popen("quarto --paths", "r"))
      --   local s = assert(f:read("*a"))
      --   f:close()
      --   return strsplit(s, "\n")[2]
      -- end

      local lua_library_files = vim.api.nvim_get_runtime_file("", true)
      local lua_plugin_paths = {}
      -- TODO: Fix Quarto
      -- local resource_path = get_quarto_resource_path()
      -- if resource_path == nil then
      --   vim.notify_once("quarto not found, lua library files not loaded")
      -- else
      --   table.insert(lua_library_files, resource_path .. "/lua-types")
      --   table.insert(lua_plugin_paths, resource_path .. "/lua-plugin/plugin.lua")
      -- end

      setup_server('lua_ls', {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            runtime = {
              version = "LuaJIT",
              plugin = lua_plugin_paths,
            },
            diagnostics = {
              globals = { "vim", "quarto", "pandoc", "io", "string", "print", "require", "table" },
              disable = { "trailing-space" },
            },
            workspace = {
              library = lua_library_files,
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      -- lspconfig.julials.setup({
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- })
      --
      -- lspconfig.bashls.setup({
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      --   filetypes = { "sh", "bash" },
      -- })

      -- Add additional languages here.
      -- See `:h lspconfig-all` for the configuration.
      -- Like e.g. Haskell:
      -- lspconfig.hls.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags
      -- }

      -- lspconfig.clangd.setup {
      --   capabilities = capabilities,
      --   flags = lsp_flags,
      -- }

      -- lspconfig.rust_analyzer.setup{
      --   capabilities = capabilities,
      --   settings = {
      --     ['rust-analyzer'] = {
      --       diagnostics = {
      --         enable = false;
      --       }
      --     }
      --   }
      -- }

      -- See https://github.com/neovim/neovim/issues/23291
      -- disable lsp watcher.
      -- Too lags on linux for python projects
      -- because pyright and nvim both create too many watchers otherwise
      if capabilities.workspace == nil then
        capabilities.workspace = {}
        capabilities.workspace.didChangeWatchedFiles = {}
      end
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      -- Python language server for definitions, hover documentation, completion, and diagnostics.
      setup_server('pyright', {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
        root_dir = function(fname)
          return util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(fname)
            or util.path.dirname(fname)
        end,
      })

      -- Start Pyright explicitly for Python buffers.  This keeps Python LSP
      -- startup reliable with Neovim's native LSP configuration API.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("python-lsp-start", { clear = true }),
        pattern = "python",
        callback = function(args)
          if #vim.lsp.get_clients({ bufnr = args.buf, name = "pyright" }) == 0 then
            vim.lsp.start(vim.lsp.config.pyright, { bufnr = args.buf })
          end
        end,
      })
    end,
  },
}
