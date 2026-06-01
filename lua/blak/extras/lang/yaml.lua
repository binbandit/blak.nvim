-- SchemaStore.nvim is pulled in lazily from the yamlls before_init hook, so
-- the schema catalog only loads when the language server actually starts.
return {
  id = "lang.yaml",
  label = "YAML",
  description = "yaml-language-server with SchemaStore schemas, Prettier, YAML Treesitter",
  treesitter = { "yaml" },
  mason = { "prettier", "prettierd" },
  lsp = {
    servers = {
      yamlls = {
        settings = {
          yaml = {
            validate = true,
            keyOrdering = false,
            -- Use SchemaStore.nvim instead of the server's bundled store.
            schemaStore = {
              enable = false,
              url = "",
            },
          },
        },
        before_init = function(_, client_config)
          local store = require("blak.util").load_plugin("SchemaStore.nvim", "schemastore")
          if not store then
            return
          end
          client_config.settings = client_config.settings or {}
          client_config.settings.yaml = client_config.settings.yaml or {}
          client_config.settings.yaml.schemas = vim.tbl_deep_extend(
            "force",
            store.yaml.schemas(),
            client_config.settings.yaml.schemas or {}
          )
        end,
      },
    },
  },
  format = {
    formatters_by_ft = {
      yaml = { "prettierd", "prettier", stop_after_first = true },
    },
  },
  plugins = {
    { "b0o/SchemaStore.nvim", lazy = true, version = false },
  },
}
