local M = {}

local managed_servers = {}
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

  if not names then
    for name in pairs(managed_servers) do
      if not config.lsp.automatic_enable or not config.lsp.servers[name] then
        vim.lsp.enable(name, false)
      end
    end
    managed_servers = {}
    for name in pairs(config.lsp.servers) do
      managed_servers[name] = true
    end
  end

  local caps = capabilities()
  for _, name in ipairs(configured_servers(config, names)) do
    local server = config.lsp.servers[name]
    local server_config = vim.tbl_deep_extend("force", {}, server, {
      capabilities = vim.tbl_deep_extend("force", {}, caps, server.capabilities or {}),
    })
    server_config = with_lua_workspace_library(name, server_config)
    -- Replace Blak's override; merging would retain settings removed on reload.
    -- Neovim still combines this with the server's runtime lsp/<name>.lua.
    vim.lsp.config[name] = server_config
  end
end

-- Restrict automatic activation to configured servers. Installed tools survive
-- disabling an extra; their presence alone must not reactivate that extra.
function M.mason_opts(config)
  local names = require("blak.util").tbl_keys(config.lsp.servers)
  return {
    ensure_installed = config.mason.automatic_install and names or {},
    automatic_enable = config.lsp.automatic_enable and names or false,
  }
end

function M.refresh(config)
  M.setup(config)
  local mason = package.loaded["mason-lspconfig"]
  if mason then
    mason.setup(M.mason_opts(config))
  end
end

function M.enable(config)
  require("blak.util").load_plugin("mason-lspconfig.nvim", "mason-lspconfig")
  M.refresh(config)
end

return M
