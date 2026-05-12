return function(config)
  return {
    {
      "stevearc/conform.nvim",
      event = { "BufWritePre" },
      cmd = { "ConformInfo" },
      opts = function()
        return {
          formatters_by_ft = config.format.formatters_by_ft,
          format_on_save = function(bufnr)
            if not config.format.enabled or vim.g.blak_disable_autoformat or vim.b[bufnr].blak_disable_autoformat then
              return nil
            end
            return {
              timeout_ms = config.format.timeout_ms,
              lsp_format = config.format.lsp_format,
            }
          end,
        }
      end,
    },
    {
      "mfussenegger/nvim-lint",
      event = config.lint.events,
      config = function()
        local lint = require("lint")
        lint.linters_by_ft = config.lint.linters_by_ft
        vim.api.nvim_create_autocmd(config.lint.events, {
          group = vim.api.nvim_create_augroup("BlakLint", { clear = true }),
          callback = function()
            local ok = pcall(lint.try_lint)
            if not ok then
              -- Missing external linters should not make editing noisy.
            end
          end,
        })
      end,
    },
  }
end
