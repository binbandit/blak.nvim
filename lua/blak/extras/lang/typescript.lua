return {
  id = "lang.typescript",
  label = "TypeScript",
  description = "ts_ls, prettier, ESLint LSP, TS/JS Treesitter",
  treesitter = { "javascript", "typescript", "tsx", "jsdoc", "json" },
  mason = { "prettier", "prettierd" },
  lsp = {
    servers = {
      ts_ls = {},
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
