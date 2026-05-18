return function(config)
  return {
    {
      "neovim/nvim-lspconfig",
      lazy = false,
      config = function()
        require("blak.core.lsp").setup(config)
      end,
    },
    {
      "mason-org/mason.nvim",
      lazy = false,
      cmd = "Mason",
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
      lazy = false,
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
