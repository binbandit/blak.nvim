local M = {}

local function capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.get_lsp_capabilities then
    caps = blink.get_lsp_capabilities(caps)
  end
  return caps
end

local function configured_servers(config, names)
  local out = {}
  if names then
    for _, name in ipairs(names) do
      if config.lsp.servers[name] then
        table.insert(out, name)
      end
    end
    return out
  end

  for name in pairs(config.lsp.servers or {}) do
    table.insert(out, name)
  end
  return out
end

function M.setup(config, names)
  vim.diagnostic.config(config.lsp.diagnostics)

  local caps = capabilities()
  for _, name in ipairs(configured_servers(config, names)) do
    local server = config.lsp.servers[name]
    local server_config = vim.tbl_deep_extend("force", {}, server, {
      capabilities = vim.tbl_deep_extend("force", {}, caps, server.capabilities or {}),
    })
    vim.lsp.config(name, server_config)
  end
end

function M.enable(config, names)
  M.setup(config, names)
  if not (config.lsp.automatic_enable and vim.lsp.enable and names and #names > 0) then
    return
  end
  local ok, err = pcall(vim.lsp.enable, names)
  if not ok then
    require("blak.util").warn("Could not enable LSP servers: " .. tostring(err))
  end
end

return M
