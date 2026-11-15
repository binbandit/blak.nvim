-- LSP servers install through mason-lspconfig: html/cssls map to html-lsp and
-- css-lsp, tailwindcss to tailwindcss-language-server, and
-- emmet_language_server to emmet-language-server. Only the Prettier
-- formatters need an explicit mason entry here.

-- The HTML and CSS servers embed a base64 "Baseline" badge image in Markdown
-- docs. Neovim floats wrap on the raw image text, so hovers and completion
-- docs fill with blank rows. Their plaintext docs carry the same text.
local plaintext_docs = {
  textDocument = {
    hover = { contentFormat = { "plaintext" } },
    completion = { completionItem = { documentationFormat = { "plaintext" } } },
  },
}

return {
  id = "lang.web",
  label = "Web",
  description = "HTML, CSS, Tailwind, and Emmet language servers with Prettier",
  treesitter = { "html", "css", "scss" },
  mason = { "prettier", "prettierd" },
  lsp = {
    servers = {
      html = { capabilities = plaintext_docs },
      cssls = { capabilities = plaintext_docs },
      -- The same server config as lang.tailwind, so enabling both is a no-op.
      tailwindcss = require("blak.extras.lang.tailwind").lsp.servers.tailwindcss,
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
