-- LSP servers install through mason-lspconfig: html/cssls map to
-- vscode-langservers-extracted, tailwindcss to tailwindcss-language-server,
-- and emmet_language_server to emmet-language-server. Only the Prettier
-- formatters need an explicit mason entry here.
return {
  id = "lang.web",
  label = "Web",
  description = "HTML, CSS, Tailwind, and Emmet language servers with Prettier",
  treesitter = { "html", "css", "scss" },
  mason = { "prettier", "prettierd" },
  lsp = {
    servers = {
      html = {},
      cssls = {},
      tailwindcss = {},
      emmet_language_server = {},
    },
  },
  format = {
    formatters_by_ft = {
      html = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
      less = { "prettierd", "prettier", stop_after_first = true },
    },
  },
}
