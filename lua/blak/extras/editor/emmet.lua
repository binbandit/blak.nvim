-- emmet_language_server installs through mason-lspconfig as
-- emmet-language-server. Abbreviations expand through the completion menu:
-- type an abbreviation such as .block and accept the suggestion. JSX and TSX
-- buffers expand with className instead of class, matching VS Code's built-in
-- Emmet. Filetypes are pinned here so the attach list stays inspectable.
return {
  id = "editor.emmet",
  label = "Emmet",
  description = "Emmet abbreviations (.block → <div class=\"block\">) through completion",
  lsp = {
    servers = {
      emmet_language_server = {
        filetypes = {
          "html",
          "css",
          "scss",
          "less",
          "sass",
          "javascriptreact",
          "typescriptreact",
          "vue",
          "svelte",
          "astro",
        },
      },
    },
  },
}
