local M = { values = nil }

local function normalize_options(value, source)
  if value == nil then
    return {}
  end
  if type(value) ~= "table" then
    require("blak.util").warn(source .. " must be a table; ignoring it.")
    return {}
  end
  return value
end

local function load_user_options()
  local util = require("blak.util")
  local ok, value = pcall(require, "blak.user")
  if ok then
    if type(value) == "function" then
      local success, result = pcall(value)
      if success then
        return normalize_options(result, "lua/blak/user.lua")
      end
      util.warn("Could not evaluate lua/blak/user.lua: " .. tostring(result))
      return {}
    end
    return normalize_options(value, "lua/blak/user.lua")
  end
  if not util.is_module_not_found(value, "blak.user") then
    util.warn("Could not load lua/blak/user.lua: " .. tostring(value))
  end
  return {}
end

function M.setup(opts)
  local defaults = require("blak.config.defaults")
  local user_opts = load_user_options()
  local g_opts = normalize_options(vim.g.blak_config, "vim.g.blak_config")
  opts = normalize_options(opts or {}, "setup(opts)")

  local config = vim.tbl_deep_extend("force", {}, defaults, g_opts, user_opts, opts)
  require("blak.config.schema").validate(config)
  require("blak.extras").apply(config)

  M.values = config
  return config
end

function M.get()
  return M.values or require("blak.config.defaults")
end

return M
