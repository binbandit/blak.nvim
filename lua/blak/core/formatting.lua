local M = {}

function M.conform_opts(config)
  return {
    formatters_by_ft = config.format.formatters_by_ft,
    default_format_opts = {
      timeout_ms = config.format.timeout_ms,
      lsp_format = config.format.lsp_format,
    },
    format_on_save = function(bufnr)
      if
        not config.format.enabled
        or vim.g.blak_disable_autoformat
        or vim.b[bufnr].blak_disable_autoformat
      then
        return nil
      end
      -- Conform resolves per-filetype options before these global defaults.
      return {}
    end,
  }
end

function M.refresh(config)
  local conform = package.loaded.conform
  if conform and conform.setup then
    local opts = require("blak.lazy").plugin_opts("conform.nvim", M.conform_opts(config))
    -- Conform.setup merges these tables, so removed filetypes otherwise linger.
    conform.formatters_by_ft = vim.deepcopy(opts.formatters_by_ft or {})
    conform.default_format_opts = vim.deepcopy(opts.default_format_opts or {})
    conform.setup(opts)
  end

  if package.loaded.lint then
    require("blak.core.linting").setup(config)
  end
end

return M
