-- SchemaStore.nvim is pulled in lazily from the jsonls before_init hook, so
-- the schema catalog only loads when the language server actually starts.
return {
  id = "lang.json",
  label = "JSON",
  description = "jsonls with SchemaStore schemas, Prettier, JSON Treesitter",
  treesitter = { "json", "jsonc" },
  mason = { "prettier", "prettierd" },
  lsp = {
    servers = {
      jsonls = {
        settings = {
          json = {
            validate = { enable = true },
          },
        },
        before_init = function(_, client_config)
          local store = require("blak.util").load_plugin("SchemaStore.nvim", "schemastore")
          if not store then
            return
          end
          client_config.settings = client_config.settings or {}
          client_config.settings.json = client_config.settings.json or {}
          client_config.settings.json.schemas = vim.list_extend(
            client_config.settings.json.schemas or {},
            store.json.schemas()
          )
        end,
      },
    },
  },
  format = {
    formatters_by_ft = {
      json = { "prettierd", "prettier", stop_after_first = true },
      jsonc = { "prettierd", "prettier", stop_after_first = true },
    },
  },
  plugins = {
    { "b0o/SchemaStore.nvim", lazy = true, version = false },
  },
}
