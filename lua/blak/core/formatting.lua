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

  require("blak.core.linting").setup(config)
end

return M
