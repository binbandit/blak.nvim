return function(config)
  local lsp_events = { "BufReadPre", "BufNewFile" }

  return {
    {
      "neovim/nvim-lspconfig",
      event = lsp_events,
      cmd = { "LspInfo", "LspStart", "LspStop", "LspRestart" },
      config = function()
        require("blak.core.lsp").setup(config)
      end,
    },
    {
      "mason-org/mason.nvim",
      cmd = "Mason",
      event = "VeryLazy",
      opts = {
        ui = {
          border = config.ui.winborder,
        },
      },
      config = function(_, opts)
        require("mason").setup(opts)
        if config.mason.automatic_install then
          vim.schedule(function()
            require("blak.core.tools").ensure(config)
          end)
        end
      end,
    },
    {
      "mason-org/mason-lspconfig.nvim",
      event = lsp_events,
      dependencies = {
        "mason-org/mason.nvim",
        "neovim/nvim-lspconfig",
      },
      opts = function()
        return {
          ensure_installed = require("blak.util").tbl_keys(config.lsp.servers),
          automatic_enable = config.lsp.automatic_enable,
        }
      end,
    },
  }
end
