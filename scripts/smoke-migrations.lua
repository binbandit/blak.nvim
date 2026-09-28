local util = require("blak.util")
local extras = require("blak.extras")
local migrations = require("blak.core.migrations")
local state_path = migrations.state_path()
local saved_state = util.read_file(state_path)
local saved_notify = util.notify
local messages = {}
util.notify = function(message)
  table.insert(messages, message)
end

local function contains(text)
  for _, message in ipairs(messages) do
    if message:find(text, 1, true) then
      return true
    end
  end
  return false
end

local function run(id, state)
  util.write_file(state_path, vim.json.encode(state))
  messages = {}
  local config = vim.deepcopy(require("blak.config.defaults"))
  config.extras.enabled = { id }
  extras.apply(config)
  local before = vim.deepcopy(config)
  assert(migrations.run(config) > 0, "new migrations were skipped")
  assert(vim.deep_equal(config, before), "migration rewrote the user's language selection")
  assert(migrations.run(config) == 0, "applied migrations repeated")
  return config
end

-- Both a fresh install and previously migrated state must explain the new
-- standard, persist acceptance, and leave the selected configuration intact.
for _, state in ipairs({
  { applied = {} },
  { applied = { ["v0.3.1.eslint_d"] = true, ["v0.3.1.native-helpers"] = true } },
}) do
  local native = run("lang.typescript", state)
  assert(native.lsp.servers.tsc and not native.lsp.servers.ts_ls)
  assert(contains("lang.typescript-legacy"), "standard TypeScript upgrade omitted the opt-out")
  assert(
    contains("Explicit ts_ls entries are preserved"),
    "upgrade omitted explicit server guidance"
  )
  local recorded = vim.json.decode(assert(util.read_file(state_path)))
  assert(recorded.applied["v0.3.1.native-typescript"], "native migration was not persisted")
  assert(recorded.applied["v0.3.1.eslint_d"], "upgrade lost prior migration state")
end

run("lang.typescript-tsgo", { applied = {} })
assert(contains("compatibility alias"), "beta alias users did not receive the upgrade guidance")

local legacy = run("lang.typescript-legacy", { applied = {} })
assert(
  legacy.lsp.servers.ts_ls and not legacy.lsp.servers.tsc,
  "upgrade replaced the legacy opt-out"
)
assert(
  not contains("lang.typescript now uses"),
  "legacy-only users received the native switch notice"
)
assert(contains("workspace SDKs"), "legacy users did not receive SDK recovery guidance")

util.notify = saved_notify
if saved_state then
  util.write_file(state_path, saved_state)
else
  vim.fn.delete(state_path)
end
print("Migration checks passed")
