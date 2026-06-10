-- Run with: NVIM_APPNAME=blak-update-contract nvim --headless -u NONE --cmd 'set loadplugins' --cmd 'lua vim.opt.rtp:prepend(vim.fn.getcwd())' -c 'lua dofile("scripts/update-contract.lua")' -c qa
-- Focused contract tests for update / upgrade / rollback behavior.

local sep = package.config:sub(1, 1)

local function join(...)
  local out = {}
  for _, part in ipairs({ ... }) do
    if part and part ~= "" then
      table.insert(out, (tostring(part):gsub("[/\\]+$", "")))
    end
  end
  return table.concat(out, sep)
end

local function read_file(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local data = fd:read("*a")
  fd:close()
  return data
end

local function write_file(path, data)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  local fd = assert(io.open(path, "w"))
  fd:write(data)
  fd:close()
end

local function restore_file(path, original)
  if original then
    write_file(path, original)
  else
    vim.fn.delete(path)
  end
end

local function assert_contains(label, text, needle)
  assert(text:find(needle, 1, true), label .. " did not contain " .. needle)
end

local function assert_not_contains(label, text, needle)
  assert(not text:find(needle, 1, true), label .. " unexpectedly contained " .. needle)
end

local config_dir = vim.fn.stdpath("config")
local state_dir = join(vim.fn.stdpath("state"), "blak")
local lockfile = join(config_dir, "lazy-lock.json")
local user_file = join(config_dir, "lua", "blak", "user.lua")
local extras_state = join(state_dir, "extras.json")
local migrations_state = join(state_dir, "migrations.json")
local update_state = join(state_dir, "update.json")
local snapshot_dir = join(state_dir, "rollbacks")
local legacy_dir = join(state_dir, "lockbacks")

local originals = {
  lockfile = read_file(lockfile),
  user_file = read_file(user_file),
  extras_state = read_file(extras_state),
  migrations_state = read_file(migrations_state),
  update_state = read_file(update_state),
}

local function reset_test_state()
  vim.fn.delete(snapshot_dir, "rf")
  vim.fn.delete(legacy_dir, "rf")
  write_file(lockfile, '{"plugins":{"before":true}}')
  write_file(user_file, 'return { picker = { provider = "fff" } }\n')
  write_file(extras_state, vim.json.encode({ enabled = { "lang.lua" } }))
  write_file(migrations_state, vim.json.encode({ applied = { "old.migration" } }))
  write_file(update_state, vim.json.encode({ channel = "stable" }))
end

local function snapshot_paths()
  return vim.fn.glob(join(snapshot_dir, "rollback-*"), false, true)
end

local function legacy_paths()
  return vim.fn.glob(join(legacy_dir, "lazy-lock-*.json"), false, true)
end

local function newest_snapshot()
  local paths = snapshot_paths()
  table.sort(paths)
  return paths[#paths]
end

local ok, err = xpcall(function()
  reset_test_state()

  -- Manifesto contract: these shipped defaults change only through an
  -- explicit upgrade path (migration plus NEWS entry), never by surprise.
  local defaults = require("blak.config.defaults")
  local function assert_default(label, actual, expected)
    assert(
      actual == expected,
      string.format("contract default changed: %s = %s, expected %s", label, vim.inspect(actual), vim.inspect(expected))
    )
  end
  assert_default("leader", defaults.leader, " ")
  assert_default("localleader", defaults.localleader, "\\")
  assert_default("picker.provider", defaults.picker.provider, "fff")
  assert_default("explorer.provider", defaults.explorer.provider, "oil")
  assert_default("terminal.provider", defaults.terminal.provider, "native")
  assert_default("lsp.automatic_enable", defaults.lsp.automatic_enable, true)

  local config = require("blak.config").setup({
    ui = { splash = { enabled = false, animate = false } },
    package = { channel = "stable", check_updates = false },
    mason = { automatic_install = false, ensure_installed = {} },
    treesitter = { ensure_installed = {} },
    lsp = { automatic_enable = false, servers = {} },
    format = { enabled = false, formatters_by_ft = {} },
    lint = { events = {}, linters_by_ft = {} },
  })
  local update = require("blak.core.update")
  update.setup(config)

  local lazy_calls = {}
  pcall(vim.api.nvim_del_user_command, "Lazy")
  vim.api.nvim_create_user_command("Lazy", function(opts)
    table.insert(lazy_calls, opts.args)
    if opts.args == "update" then
      vim.api.nvim_exec_autocmds("User", { pattern = "LazyUpdatePre", modeline = false })
    end
  end, { nargs = "*" })

  assert(update.update() == true, "BlakUpdate should succeed without channel/migration blockers")
  assert(lazy_calls[#lazy_calls] == "update", "BlakUpdate did not run Lazy update")
  assert(#snapshot_paths() == 1, "BlakUpdate should create one rollback snapshot")
  assert(#legacy_paths() == 1, "BlakUpdate should keep one legacy lockfile backup")

  local first = newest_snapshot()
  local manifest = vim.json.decode(read_file(join(first, "manifest.json")))
  assert(manifest.kind == "update", "snapshot manifest should record update kind")
  assert(manifest.channel == "stable", "snapshot manifest should record stable channel")
  assert_contains("snapshot lockfile", read_file(join(first, "lazy-lock.json")) or "", '"before"')
  assert_contains("snapshot user.lua", read_file(join(first, "user.lua")) or "", 'provider = "fff"')
  assert_contains("snapshot extras", read_file(join(first, "extras.json")) or "", "lang.lua")
  assert_contains("snapshot migrations", read_file(join(first, "migrations.json")) or "", "old.migration")
  assert_contains("snapshot update state", read_file(join(first, "update.json")) or "", '"stable"')

  config.package.channel = "edge"
  local lazy_count = #lazy_calls
  assert(update.update() == false, "BlakUpdate should reject channel changes")
  assert(#lazy_calls == lazy_count, "channel-blocked BlakUpdate should not call Lazy update")
  config.package.channel = "stable"

  local real_migrations = package.loaded["blak.core.migrations"]
  package.loaded["blak.core.migrations"] = {
    blocking = function()
      return {
        { id = "contract.breaking", description = "Contract test breaking migration" },
      }
    end,
  }
  assert(update.update() == false, "BlakUpdate should reject pending breaking migrations")
  assert(#lazy_calls == lazy_count, "migration-blocked BlakUpdate should not call Lazy update")

  local migration_ran = false
  package.loaded["blak.core.migrations"] = {
    blocking = function()
      return {}
    end,
    run = function()
      migration_ran = true
      write_file(user_file, 'return { picker = { provider = "snacks" } }\n')
      write_file(migrations_state, vim.json.encode({ applied = { "contract.breaking" } }))
      return 1
    end,
  }
  config.package.channel = "edge"
  assert(update.upgrade() == true, "BlakUpgrade should succeed")
  assert(migration_ran, "BlakUpgrade did not run migrations")
  assert(lazy_calls[#lazy_calls] == "update", "BlakUpgrade did not run Lazy update")
  assert_contains("accepted channel", read_file(update_state) or "", '"edge"')
  assert_contains("post-upgrade user.lua", read_file(user_file) or "", 'provider = "snacks"')
  assert(#snapshot_paths() == 2, "BlakUpgrade should create a second rollback snapshot")
  package.loaded["blak.core.migrations"] = real_migrations

  write_file(lockfile, '{"plugins":{"after":true}}')
  write_file(extras_state, vim.json.encode({ enabled = { "lang.rust" } }))
  update.rollback()
  assert(lazy_calls[#lazy_calls] == "restore", "BlakRollback did not run Lazy restore")
  assert_contains("rolled back lockfile", read_file(lockfile) or "", '"before"')
  assert_contains("rolled back user.lua", read_file(user_file) or "", 'provider = "fff"')
  assert_not_contains("rolled back user.lua", read_file(user_file) or "", 'provider = "snacks"')
  assert_contains("rolled back extras", read_file(extras_state) or "", "lang.lua")
  assert_contains("rolled back migrations", read_file(migrations_state) or "", "old.migration")
  assert_contains("rolled back update state", read_file(update_state) or "", '"stable"')

  vim.fn.delete(snapshot_dir, "rf")
  vim.fn.delete(legacy_dir, "rf")
  write_file(lockfile, '{"plugins":{"legacy":true}}')
  update.backup()
  local legacy = legacy_paths()
  assert(#legacy == 1, "manual backup should create a legacy lockfile backup")
  local snapshot = newest_snapshot()
  assert(snapshot and read_file(join(snapshot, "manifest.json")), "manual backup should create a manifest snapshot")
  vim.fn.delete(snapshot_dir, "rf")
  write_file(lockfile, '{"plugins":{"current":true}}')
  update.rollback()
  assert_contains("legacy rollback lockfile", read_file(lockfile) or "", '"legacy"')
end, debug.traceback)

restore_file(lockfile, originals.lockfile)
restore_file(user_file, originals.user_file)
restore_file(extras_state, originals.extras_state)
restore_file(migrations_state, originals.migrations_state)
restore_file(update_state, originals.update_state)
vim.fn.delete(snapshot_dir, "rf")
vim.fn.delete(legacy_dir, "rf")

if not ok then
  error(err)
end
