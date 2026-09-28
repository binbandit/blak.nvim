return {
  id = "lang.typescript-tsgo",
  label = "TypeScript (tsgo compatibility)",
  description = "Compatibility alias for the native lang.typescript stack",
  alias = "lang.typescript",
  apply = function(config)
    local servers = config.lsp.servers
    if servers.tsgo then
      -- Keep the saved extra ID and carry existing tsgo overrides forward.
      -- Explicit settings under the current server name take precedence.
      servers.tsc = vim.tbl_deep_extend("force", {}, servers.tsgo, servers.tsc or {})
      servers.tsgo = nil
      return true
    end
  end,
}
