return {
  id = "lang.typescript-tsgo",
  label = "TypeScript (tsgo)",
  description = "tsgo, prettier, ESLint LSP, TS/JS Treesitter",
  treesitter = { "javascript", "typescript", "tsx", "jsdoc", "json" },
  mason = { "prettier", "prettierd" },
  lsp = {
    servers = {
      tsgo = {},
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
  apply = function(config)
    if config.lsp and config.lsp.servers then
      config.lsp.servers.ts_ls = nil
    end
  end,
}
