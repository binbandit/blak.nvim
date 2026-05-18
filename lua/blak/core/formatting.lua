local M = {}

function M.conform_opts(config)
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
end

function M.refresh(config)
  local ok_conform, conform = pcall(require, "conform")
  if ok_conform and conform.setup then
    conform.setup(M.conform_opts(config))
  end

  local ok_lint, lint = pcall(require, "lint")
  if ok_lint then
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
  end
end

return M
