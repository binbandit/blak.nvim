local M = { values = nil }

local setup_opts = {}
local user_path

local function normalize_options(value, source, strict)
  if value == nil then
    return {}
  end
  if type(value) ~= "table" then
    if strict then
      error(source .. " must be a table")
    end
    require("blak.util").warn(source .. " must be a table; ignoring it.")
    return {}
  end
  return value
end

local function find_user_path()
  local util = require("blak.util")
  for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/blak/user.lua", false)) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end

  local path = util.join(vim.fn.stdpath("config"), "lua", "blak", "user.lua")
  if vim.fn.filereadable(path) == 1 then
    return path
  end
  return nil
end

local function normalize_user_value(value, options)
  if type(value) == "function" then
    local success, result = pcall(value)
    if success then
      return normalize_options(result, "lua/blak/user.lua", options.strict_user)
    end
    if options.strict_user then
      error("Could not evaluate lua/blak/user.lua: " .. tostring(result))
    end
    require("blak.util").warn("Could not evaluate lua/blak/user.lua: " .. tostring(result))
    return {}
  end
  return normalize_options(value, "lua/blak/user.lua", options.strict_user)
end

local function load_user_file(path, options)
  local chunk, err = loadfile(path)
  if not chunk then
    if options.strict_user then
      error("Could not load lua/blak/user.lua: " .. tostring(err))
    end
    require("blak.util").warn("Could not load lua/blak/user.lua: " .. tostring(err))
    return {}
  end

  local ok, value = pcall(chunk)
  if not ok then
    if options.strict_user then
      error("Could not load lua/blak/user.lua: " .. tostring(value))
    end
    require("blak.util").warn("Could not load lua/blak/user.lua: " .. tostring(value))
    return {}
  end
  return normalize_user_value(value, options)
end

local function load_user_options(options)
  options = options or {}
  local util = require("blak.util")
  local path = find_user_path() or user_path
  if path then
    user_path = path
  end
  if options.strict_user and path and vim.fn.filereadable(path) == 1 then
    return load_user_file(path, options)
  end

  local ok, value = pcall(require, "blak.user")
  if ok then
    return normalize_user_value(value, options)
  end
  if not util.is_module_not_found(value, "blak.user") then
    if options.strict_user then
      error("Could not load lua/blak/user.lua: " .. tostring(value))
    end
    util.warn("Could not load lua/blak/user.lua: " .. tostring(value))
  end
  return {}
end

local function build(opts, options)
  options = options or {}
  local defaults = require("blak.config.defaults")
  local user_opts = load_user_options(options)
  local g_opts = normalize_options(vim.g.blak_config, "vim.g.blak_config")
  opts = normalize_options(opts or {}, "setup(opts)")

  local config = vim.tbl_deep_extend("force", {}, defaults, g_opts, user_opts, opts)
  require("blak.config.schema").validate(config)
  require("blak.extras").apply(config)

  return config
end

function M.setup(opts)
  setup_opts = opts or {}
  local config = build(setup_opts)
  M.values = config
  return config
end

function M.reload()
  package.loaded["blak.user"] = nil
  if vim.loader and vim.loader.reset then
    pcall(vim.loader.reset, "blak.user")
  end
  local config = build(setup_opts, { strict_user = true })
  M.values = config
  return config
end

function M.get()
  return M.values or require("blak.config.defaults")
end

return M
