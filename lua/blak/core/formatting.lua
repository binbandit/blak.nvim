local M = {}

function M.conform_opts(config)
  return {
    formatters_by_ft = config.format.formatters_by_ft,
    format_on_save = function(bufnr)
      if
        not config.format.enabled
        or vim.g.blak_disable_autoformat
        or vim.b[bufnr].blak_disable_autoformat
      then
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
  local conform = package.loaded.conform
  if conform and conform.setup then
    local opts = require("blak.lazy").plugin_opts("conform.nvim", M.conform_opts(config))
    -- Conform.setup merges these tables, so removed filetypes otherwise linger.
    conform.formatters_by_ft = vim.deepcopy(opts.formatters_by_ft or {})
    conform.setup(opts)
  end

  if package.loaded.lint then
    require("blak.core.linting").setup(config)
  end
end

return M
