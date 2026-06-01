-- zls provides formatting through its built-in `zig fmt`, and Blak's core
-- format config already falls back to the LSP formatter, so no separate
-- formatter is declared here.
return {
  id = "lang.zig",
  label = "Zig",
  description = "zls language server (zig fmt) and Zig Treesitter",
  treesitter = { "zig" },
  lsp = {
    servers = {
      zls = {},
    },
  },
}
