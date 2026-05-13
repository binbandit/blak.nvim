return {
  id = "lang.python",
  label = "Python",
  description = "pyright, black/isort, ruff, Python Treesitter",
  treesitter = { "python" },
  mason = { "black", "isort", "ruff" },
  lsp = {
    servers = {
      pyright = {},
      ruff = {},
    },
  },
  format = {
    formatters_by_ft = {
      python = { "isort", "black" },
    },
  },
  lint = {
    linters_by_ft = {
      python = { "ruff" },
    },
  },
}
