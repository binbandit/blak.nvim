-- Nix users install nixfmt with Nix itself (`nix profile install nixpkgs#nixfmt`).
-- Mason's nixfmt package only ships a linux x64 binary, so installing it through
-- Mason fails on every other platform. Conform skips nixfmt until it is on $PATH.
return {
  id = "lang.nix",
  label = "Nix",
  description = "nil language server, nixfmt, Nix Treesitter",
  treesitter = { "nix" },
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
