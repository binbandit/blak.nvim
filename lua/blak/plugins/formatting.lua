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
        local lint = require("lint")
        lint.linters_by_ft = config.lint.linters_by_ft
        if #(config.lint.events or {}) > 0 then
          vim.api.nvim_create_autocmd(config.lint.events, {
            group = vim.api.nvim_create_augroup("BlakLint", { clear = true }),
            callback = function()
              local ok = pcall(lint.try_lint)
              if not ok then
                -- Missing external linters should not make editing noisy.
              end
            end,
          })
        end
      end,
    },
  }
end
