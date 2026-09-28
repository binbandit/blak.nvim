return {
  id = "lang.python-pro",
  label = "Python Pro",
  description = "BasedPyright, Ruff format/code actions, venv selector, debugpy",
  supersedes = { "lang.python" },
  treesitter = { "python", "requirements" },
  mason = { "debugpy", "ruff" },
  lsp = {
    servers = {
      basedpyright = {},
      ruff = {},
    },
  },
  format = {
    formatters_by_ft = {
      python = { "ruff_organize_imports", "ruff_format" },
    },
  },
  plugins = {
    {
      "linux-cultist/venv-selector.nvim",
      ft = "python",
      cmd = { "VenvSelect", "VenvSelectCache", "VenvSelectLog" },
      opts = {
        options = {
          picker = "snacks",
        },
      },
    },
  },
  keys = {
    { lhs = "<leader>cv", rhs = "<cmd>VenvSelect<cr>", desc = "Python virtualenv" },
  },
}
