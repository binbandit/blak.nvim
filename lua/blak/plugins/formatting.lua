return function(config)
  return {
    {
      "stevearc/conform.nvim",
      event = { "BufWritePre" },
      cmd = { "ConformInfo" },
      opts = function()
        return require("blak.core.formatting").conform_opts(config)
      end,
    },
    {
      "mfussenegger/nvim-lint",
      event = config.lint.events,
      config = function()
        require("blak.core.linting").setup(config)
      end,
    },
  }
end
