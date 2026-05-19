local M = {}

local lua_runtime_library

local function capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local completion = vim.tbl_get(caps, "textDocument", "completion")
  if completion then
    completion.insertTextMode = 1
    completion.completionItem = completion.completionItem or {}
    completion.completionItem.insertTextModeSupport = { valueSet = { 1 } }
    completion.completionItem.labelDetailsSupport = true
  end

  local blink = package.loaded["blink.cmp"]
  if blink and blink.get_lsp_capabilities then
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

local function runtime_library()
  if not lua_runtime_library then
    lua_runtime_library = vim.api.nvim_get_runtime_file("", true)
  end
  return lua_runtime_library
end

local function with_lua_workspace_library(name, server_config)
  if name ~= "lua_ls" then
    return server_config
  end

  local workspace = vim.tbl_get(server_config, "settings", "Lua", "workspace")
  if workspace and workspace.library ~= nil then
    return server_config
  end

  server_config.settings = server_config.settings or {}
  server_config.settings.Lua = server_config.settings.Lua or {}
  server_config.settings.Lua.workspace = vim.tbl_deep_extend("force", {}, workspace or {}, {
    library = runtime_library(),
  })
  return server_config
end

function M.setup(config, names)
  vim.diagnostic.config(config.lsp.diagnostics)

  local caps = capabilities()
  for _, name in ipairs(configured_servers(config, names)) do
    local server = config.lsp.servers[name]
    local server_config = vim.tbl_deep_extend("force", {}, server, {
      capabilities = vim.tbl_deep_extend("force", {}, caps, server.capabilities or {}),
    })
    server_config = with_lua_workspace_library(name, server_config)
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
