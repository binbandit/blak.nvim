return {
  id = "lang.typescript",
  label = "TypeScript",
  description = "TypeScript 7 native LSP, prettier, ESLint LSP, TS/JS Treesitter",
  supersedes = { "lang.typescript-legacy" },
  treesitter = { "javascript", "typescript", "tsx", "jsdoc", "json" },
  mason = { "prettier", "prettierd" },
  lsp = {
    servers = {
      -- tsc prefers UTF-8 and ESLint only speaks UTF-16; one encoding per
      -- buffer keeps `:checkhealth vim.lsp` free of mixed-encoding warnings.
      tsc = {
        capabilities = { general = { positionEncodings = { "utf-16" } } },
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
