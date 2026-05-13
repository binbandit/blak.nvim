return {
  id = "lang.go",
  label = "Go",
  description = "gopls, goimports/gofumpt, golangci-lint, Go Treesitter",
  treesitter = { "go", "gomod", "gosum", "gowork" },
  mason = { "goimports", "gofumpt", "golangci-lint" },
  lsp = {
    servers = {
      gopls = {},
    },
  },
  format = {
    formatters_by_ft = {
      go = { "goimports", "gofumpt" },
    },
  },
  lint = {
    linters_by_ft = {
      go = { "golangcilint" },
    },
  },
}
