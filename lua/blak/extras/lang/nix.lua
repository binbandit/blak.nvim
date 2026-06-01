return {
  id = "lang.nix",
  label = "Nix",
  description = "nil language server, nixfmt, Nix Treesitter",
  treesitter = { "nix" },
  mason = { "nixfmt" },
  lsp = {
    servers = {
      nil_ls = {},
    },
  },
  format = {
    formatters_by_ft = {
      nix = { "nixfmt" },
    },
  },
}
