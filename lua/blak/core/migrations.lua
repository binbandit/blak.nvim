local M = {}

-- Add breaking migrations here before changing stable workflow defaults.
-- A breaking migration blocks :BlakUpdate and only runs through :BlakUpgrade.
local migrations = {}

local function state_path()
  return require("blak.util").join(vim.fn.stdpath("state"), "blak", "migrations.json")
end

local function read_state()
  local util = require("blak.util")
  local data = util.read_file(state_path())
  if not data or data == "" then
    return { applied = {} }
  end

  local ok, decoded = pcall(vim.json.decode, data)
  if not ok or type(decoded) ~= "table" then
    util.warn("Could not parse migration state; pending migrations will be rechecked.")
    return { applied = {} }
  end

  local applied = {}
  if type(decoded.applied) == "table" then
    for key, value in pairs(decoded.applied) do
      if type(key) == "number" and type(value) == "string" then
        applied[value] = true
      elseif value == true then
        applied[key] = true
      end
    end
  end

  return { applied = applied }
end

local function write_state(state)
  require("blak.util").write_file(state_path(), vim.json.encode(state))
end

local function migration_applies(migration, config)
  if not migration.channels then
    return true
  end
  local channel = vim.tbl_get(config, "package", "channel")
  for _, candidate in ipairs(migration.channels) do
    if candidate == channel then
      return true
    end
  end
  return false
end

local function all()
  return migrations
end

function M.state_path()
  return state_path()
end

function M.pending(config, opts)
  opts = opts or {}
  config = config or require("blak.config").get()

  local state = read_state()
  local pending = {}
  for _, migration in ipairs(all()) do
    if not state.applied[migration.id] and migration_applies(migration, config) then
      if not opts.breaking_only or migration.breaking then
        table.insert(pending, migration)
      end
    end
  end
  return pending
end

function M.blocking(config)
  return M.pending(config, { breaking_only = true })
end

function M.run(config)
  config = config or require("blak.config").get()

  local state = read_state()
  local pending = M.pending(config)
  if #pending == 0 then
    return 0
  end

  local context = {
    config = config,
    state_path = state_path(),
    util = require("blak.util"),
  }

  for _, migration in ipairs(pending) do
    if migration.apply then
      migration.apply(config, context)
    end
    state.applied[migration.id] = true
  end
  write_state(state)

  require("blak.util").notify("Applied " .. #pending .. " Blak upgrade migration" .. (#pending == 1 and "" or "s"))
  return #pending
end

return M
