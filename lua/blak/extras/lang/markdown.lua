return {
  id = "lang.markdown",
  label = "Markdown",
  description = "marksman, prettier, markdownlint, Markdown Treesitter",
  treesitter = { "markdown", "markdown_inline" },
  mason = { "prettier", "prettierd", "markdownlint" },
  lsp = {
    servers = {
      marksman = {},
    },
  },
  format = {
    formatters_by_ft = {
      markdown = { "prettierd", "prettier", stop_after_first = true },
    },
  },
  lint = {
    linters_by_ft = {
      markdown = { "markdownlint" },
    },
  },
}
