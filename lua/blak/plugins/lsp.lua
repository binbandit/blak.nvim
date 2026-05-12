local function lsp_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.get_lsp_capabilities then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end
  return capabilities
end

local function setup_servers(config)
  vim.diagnostic.config(config.lsp.diagnostics)

  local capabilities = lsp_capabilities()
  for name, server in pairs(config.lsp.servers or {}) do
    local server_config = vim.tbl_deep_extend("force", {}, server, {
      capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {}),
    })
    vim.lsp.config(name, server_config)
  end
end

return function(config)
  return {
    {
      "neovim/nvim-lspconfig",
      lazy = false,
      config = function()
        setup_servers(config)
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
