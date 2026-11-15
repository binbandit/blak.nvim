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
  -- lang.python-pro reuses these. Enabling both still sets each adapter up
  -- once: the specs merge into the same plugins and adapter names.
  integrations = {
    ["debug.dap"] = {
      mason = { "debugpy" },
      plugins = {
        {
          "mfussenegger/nvim-dap",
          lazy = true,
          dependencies = { "mfussenegger/nvim-dap-python" },
        },
        {
          "mfussenegger/nvim-dap-python",
          lazy = true,
          -- Mason's debugpy-adapter runs debugpy from its own venv. The
          -- program runs with the active virtualenv or a venv/.venv in the
          -- project, so debugpy does not need to be in the project.
          config = function()
            require("dap-python").setup("debugpy-adapter")
          end,
        },
      },
    },
    ["test.neotest"] = {
      plugins = {
        {
          "nvim-neotest/neotest",
          lazy = true,
          dependencies = { "nvim-neotest/neotest-python" },
          opts = {
            adapters = {
              ["neotest-python"] = {},
            },
          },
        },
      },
    },
  },
}
