return {
  id = "lang.typescript-tsgo",
  label = "TypeScript (tsgo)",
  description = "tsgo, prettier, eslint_d, TS/JS Treesitter",
  treesitter = { "javascript", "typescript", "tsx", "jsdoc", "json" },
  mason = { "prettier", "prettierd", "eslint_d" },
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
  lint = {
    linters_by_ft = {
      javascript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
    },
  },
  apply = function(config)
    if config.lsp and config.lsp.servers then
      config.lsp.servers.ts_ls = nil
    end
  end,
}
