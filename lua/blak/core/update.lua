local M = {}
local skip_next_lazy_update_backup = false

local function state_path(...)
  return require("blak.util").join(vim.fn.stdpath("state"), "blak", ...)
end

local function lockfile()
  return require("blak.util").join(vim.fn.stdpath("config"), "lazy-lock.json")
end

local function user_config()
  return require("blak.util").join(vim.fn.stdpath("config"), "lua", "blak", "user.lua")
end

local function extras_state()
  return state_path("extras.json")
end

local function migrations_state()
  return state_path("migrations.json")
end

local function update_state()
  return state_path("update.json")
end

local function snapshot_dir()
  return state_path("rollbacks")
end

local function legacy_backup_dir()
  return state_path("lockbacks")
end

local function timestamp()
  return os.date("%Y%m%d-%H%M%S")
end

local function next_legacy_backup_path()
  local util = require("blak.util")
  local dir = legacy_backup_dir()
  local stamp = timestamp()
  local path = util.join(dir, "lazy-lock-" .. stamp .. ".json")
  if not util.file_exists(path) then
    return path
  end

  for index = 1, 999 do
    path = util.join(dir, string.format("lazy-lock-%s-%03d.json", stamp, index))
    if not util.file_exists(path) then
      return path
    end
  end

  local uv = vim.uv or vim.loop
  return util.join(dir, string.format("lazy-lock-%s-%s.json", stamp, uv.hrtime()))
end

local function next_snapshot_path()
  local util = require("blak.util")
  local dir = snapshot_dir()
  local stamp = timestamp()
  local path = util.join(dir, "rollback-" .. stamp)
  if not util.file_exists(path) then
    return path
  end

  for index = 1, 999 do
    path = util.join(dir, string.format("rollback-%s-%03d", stamp, index))
    if not util.file_exists(path) then
      return path
    end
  end

  local uv = vim.uv or vim.loop
  return util.join(dir, string.format("rollback-%s-%s", stamp, uv.hrtime()))
end

local function legacy_backup_order(path)
  local name = vim.fn.fnamemodify(path, ":t")
  local stamp, suffix = name:match("^lazy%-lock%-(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)%-?(%d*)%.json$")
  if stamp then
    return stamp, tonumber(suffix) or 0
  end
  return name, 0
end

local function snapshot_order(path)
  local name = vim.fn.fnamemodify(path, ":t")
  local stamp, suffix = name:match("^rollback%-(%d%d%d%d%d%d%d%d%-%d%d%d%d%d%d)%-?(%d*)$")
  if stamp then
    return stamp, tonumber(suffix) or 0
  end
  return name, 0
end

local function latest_rollback_point()
  local util = require("blak.util")
  local candidates = {}

  for _, path in ipairs(vim.fn.glob(util.join(snapshot_dir(), "rollback-*"), false, true)) do
    local stamp, suffix = snapshot_order(path)
    table.insert(candidates, { kind = "snapshot", path = path, stamp = stamp, suffix = suffix, priority = 2 })
  end

  for _, path in ipairs(vim.fn.glob(util.join(legacy_backup_dir(), "lazy-lock-*.json"), false, true)) do
    local stamp, suffix = legacy_backup_order(path)
    table.insert(candidates, { kind = "legacy", path = path, stamp = stamp, suffix = suffix, priority = 1 })
  end

  table.sort(candidates, function(a, b)
    if a.stamp == b.stamp then
      if a.suffix == b.suffix then
        return a.priority < b.priority
      end
      return a.suffix < b.suffix
    end
    return a.stamp < b.stamp
  end)
  return candidates[#candidates]
end

local function tracked_files()
  return {
    { key = "lockfile", label = "lazy-lock.json", path = lockfile(), filename = "lazy-lock.json" },
    { key = "user_config", label = "lua/blak/user.lua", path = user_config(), filename = "user.lua" },
    { key = "extras_state", label = "extras state", path = extras_state(), filename = "extras.json" },
    { key = "migrations_state", label = "migration state", path = migrations_state(), filename = "migrations.json" },
    { key = "update_state", label = "update state", path = update_state(), filename = "update.json" },
  }
end

local function write_manifest(path, manifest)
  require("blak.util").write_file(path, vim.json.encode(manifest))
end

local function read_manifest(path)
  local data = require("blak.util").read_file(path)
  if not data then
    return nil
  end
  local ok, decoded = pcall(vim.json.decode, data)
  if ok and type(decoded) == "table" then
    return decoded
  end
  return nil
end

local function snapshot(kind)
  local util = require("blak.util")
  local path = next_snapshot_path()
  util.mkdir(path)

  local config = require("blak.config").get()
  local manifest = {
    version = 1,
    kind = kind or "manual",
    channel = vim.tbl_get(config, "package", "channel"),
    created_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    files = {},
  }

  for _, file in ipairs(tracked_files()) do
    local exists = util.file_exists(file.path)
    local entry = {
      key = file.key,
      label = file.label,
      path = file.path,
      filename = file.filename,
      exists = exists,
    }
    if exists then
      entry.exists = util.copy_file(file.path, util.join(path, file.filename))
      if not entry.exists then
        util.warn("Could not snapshot " .. file.label)
      end
    end
    table.insert(manifest.files, entry)
  end

  write_manifest(util.join(path, "manifest.json"), manifest)

  if util.file_exists(lockfile()) then
    util.mkdir(legacy_backup_dir())
    util.copy_file(lockfile(), next_legacy_backup_path())
  end

  return path
end

local function restore_file(snapshot_path, entry)
  local util = require("blak.util")
  if entry.exists then
    local source = util.join(snapshot_path, entry.filename)
    if not util.copy_file(source, entry.path) then
      util.warn("Could not restore " .. (entry.label or entry.key or entry.path))
      return false
    end
    return true
  end

  vim.fn.delete(entry.path)
  return true
end

local function restore_snapshot(path)
  local util = require("blak.util")
  local manifest = read_manifest(util.join(path, "manifest.json"))
  if not manifest then
    if util.copy_file(util.join(path, "lazy-lock.json"), lockfile()) then
      return true
    end
    util.warn("Rollback snapshot is missing a manifest: " .. vim.fn.fnamemodify(path, ":t"))
    return false
  end

  local restored = false
  local ok = true
  for _, entry in ipairs(manifest.files or {}) do
    local entry_ok = restore_file(path, entry)
    ok = entry_ok and ok
    restored = entry_ok or restored
  end
  return ok and restored
end

local function reload_config()
  local reload = package.loaded["blak.core.reload"] or require("blak.util").try_require("blak.core.reload")
  if reload and reload.reload then
    pcall(reload.reload, { notify = false })
  end
end

local function pending_breaking_migrations(config)
  local migrations = require("blak.core.migrations")
  if not migrations.blocking then
    return {}
  end
  return migrations.blocking(config)
end

local function read_update_state()
  local data = require("blak.util").read_file(update_state())
  if not data or data == "" then
    return {}
  end
  local ok, decoded = pcall(vim.json.decode, data)
  if ok and type(decoded) == "table" then
    return decoded
  end
  return {}
end

local function write_update_state(state)
  require("blak.util").write_file(update_state(), vim.json.encode(state))
end

local function current_channel(config)
  return vim.tbl_get(config, "package", "channel") or "stable"
end

local function ensure_update_state(config)
  local state = read_update_state()
  if not state.channel then
    state.channel = current_channel(config)
    write_update_state(state)
  end
  return state
end

local function changed_channel(config)
  local state = ensure_update_state(config)
  local channel = current_channel(config)
  if state.channel ~= channel then
    return state.channel, channel
  end
  return nil, nil
end

local function accept_channel(channel)
  local state = read_update_state()
  state.channel = channel
  write_update_state(state)
end

local function describe_migrations(migrations)
  local lines = {}
  for _, migration in ipairs(migrations or {}) do
    table.insert(lines, migration.id .. ": " .. (migration.description or "migration required"))
  end
  return table.concat(lines, "\n")
end

local function lazy_update(kind)
  local dest = snapshot(kind)
  skip_next_lazy_update_backup = dest ~= nil
  local ok, err = pcall(vim.cmd, "Lazy update")
  if skip_next_lazy_update_backup then
    skip_next_lazy_update_backup = false
  end
  if not ok then
    error(err)
  end
end

function M.backup()
  return snapshot("manual")
end

function M.setup(config)
  ensure_update_state(config)

  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyUpdatePre",
    group = vim.api.nvim_create_augroup("BlakUpdate", { clear = true }),
    callback = function()
      if skip_next_lazy_update_backup then
        skip_next_lazy_update_backup = false
        return
      end
      local dest = M.backup()
      if dest then
        require("blak.util").notify("Rollback snapshot created: " .. vim.fn.fnamemodify(dest, ":t"))
      end
    end,
  })
end

function M.update()
  local config = require("blak.config").get()
  local previous_channel, next_channel = changed_channel(config)
  if previous_channel then
    require("blak.util").warn(
      "BlakUpdate blocked: package.channel changed from "
        .. previous_channel
        .. " to "
        .. next_channel
        .. ". Run :BlakUpgrade to accept channel changes."
    )
    return false
  end

  local pending = pending_breaking_migrations(config)
  if #pending > 0 then
    require("blak.util").warn(
      "BlakUpdate blocked by pending upgrade migrations:\n"
        .. describe_migrations(pending)
        .. "\nRun :BlakUpgrade to snapshot config, apply migrations, and update."
    )
    return false
  end

  lazy_update("update")
  return true
end

function M.upgrade()
  local util = require("blak.util")
  local config = require("blak.config").get()
  local accepted_channel = current_channel(config)
  local dest = snapshot("upgrade")
  local migrations = require("blak.core.migrations")
  local ran = 0
  if migrations.run then
    ran = migrations.run(config)
  end
  if ran > 0 then
    reload_config()
    config = require("blak.config").get()
  end
  accept_channel(accepted_channel)
  util.notify(
    "Upgrade mode: rollback snapshot "
      .. vim.fn.fnamemodify(dest, ":t")
      .. " created. Review Lazy changes before accepting workflow-affecting plugin swaps."
  )
  skip_next_lazy_update_backup = dest ~= nil
  local ok, err = pcall(vim.cmd, "Lazy update")
  if skip_next_lazy_update_backup then
    skip_next_lazy_update_backup = false
  end
  if not ok then
    error(err)
  end
  return true
end

function M.rollback()
  local util = require("blak.util")
  local latest = latest_rollback_point()
  if not latest then
    util.warn("No rollback snapshot found.")
    return
  end

  if latest.kind == "snapshot" then
    if not restore_snapshot(latest.path) then
      return
    end
  else
    util.copy_file(latest.path, lockfile())
  end

  reload_config()
  util.notify("Restored " .. vim.fn.fnamemodify(latest.path, ":t") .. ". Running :Lazy restore.")
  vim.cmd("Lazy restore")
end

function M.news()
  local root = vim.fn.stdpath("config")
  local news = require("blak.util").join(root, "NEWS.md")
  if vim.fn.filereadable(news) == 1 then
    vim.cmd.edit(news)
  else
    require("blak.util").open_scratch("Blak news", {
      "Blak v0.2.0",
      "",
      "Extras UI, live extras activation, safer update and upgrade flows, typed config metadata, theme adapters, sparse install, expanded docs, and startup deferral.",
    })
  end
end

return M
