return {
  id = "lang.typescript-legacy",
  label = "TypeScript (legacy)",
  description = "ts_ls with a compatible SDK, prettier, ESLint LSP, TS/JS Treesitter",
  treesitter = { "javascript", "typescript", "tsx", "jsdoc", "json" },
  mason = { "prettier", "prettierd" },
  lsp = {
    servers = {
      ts_ls = {
        before_init = function(params, config)
          require("blak.providers.typescript").before_init(params, config)
        end,
      },
      eslint = {},
    },
  },
  format = {
    formatters_by_ft = {
      javascript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      jsonc = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
