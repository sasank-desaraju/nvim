return {
  {
    "madox2/vim-ai",
    enabled = true,
    lazy = false,
    priority = 1000
  },


  {
    "Robitx/gp.nvim",
    enabled = true,
    lazy = false,
    config = function()
      require("gp").setup({

        -- at least one working provider is required
        -- to disable a provider set it to empty table like openai = {}
        providers = {
          -- secrets can be strings or tables with command and arguments
          -- secret = { "cat", "path_to/openai_api_key" },
          -- secret = { "bw", "get", "password", "OPENAI_API_KEY" },
          -- secret : "sk-...",
          -- secret = os.getenv("env_name.."),
          openai = {
            disable = false,
            endpoint = "https://api.openai.com/v1/chat/completions",
            secret = os.getenv("OPENAI_API_KEY"),
          },
          copilot = {
            disable = false,
            endpoint = "https://api.githubcopilot.com/chat/completions",
            secret = {
              "bash",
              "-c",
              "cat ~/.config/github-copilot/hosts.json | sed -e 's/.*oauth_token...//;s/\".*//'",
            },
          },
          ollama = {
            disable = true,
            endpoint = "http://localhost:11434/v1/chat/completions",
            secret = "dummy_secret",
          },
          pplx = {
            disable = false,
            endpoint = "https://api.perplexity.ai/chat/completions",
            secret = os.getenv("PPLX_API_KEY"),
          },
        },
      })
    end,
  }

}
