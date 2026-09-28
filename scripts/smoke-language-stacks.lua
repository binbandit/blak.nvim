-- Language stacks must behave the same on startup and when enabled live.
local extras = require("blak.extras")
local defaults = require("blak.config.defaults")

local function config()
  return vim.deepcopy(defaults)
end

local function apply(ids, value)
  value = value or config()
  for _, id in ipairs(ids) do
    extras.apply_one(value, id)
  end
  require("blak.config.schema").validate(value)
  return value
end

local dim = apply({ "ui.dim" })
dim.snacks.dim.enabled = false
local fresh_dim = apply({ "ui.dim" })
assert(fresh_dim.snacks.dim.enabled, "changing a Snacks option leaked into future extra defaults")
local disabled_dim = config()
disabled_dim.snacks.dim = { enabled = false }
apply({ "ui.dim" }, disabled_dim)
assert(disabled_dim.snacks.dim.enabled == false, "the extra overrode an explicit Snacks setting")

for _, pair in ipairs({
  { "lang.python", "lang.python-pro", "pyright", "basedpyright" },
  { "lang.typescript-legacy", "lang.typescript", "ts_ls", "tsc" },
  { "lang.typescript-legacy", "lang.typescript-tsgo", "ts_ls", "tsc" },
}) do
  local forward = apply({ pair[1], pair[2] })
  local reverse = apply({ pair[2], pair[1] })
  for _, field in ipairs({ "lsp", "format", "lint", "mason", "treesitter" }) do
    assert(
      vim.deep_equal(forward[field], reverse[field]),
      pair[1] .. " depends on activation order: " .. field
    )
  end
  assert(forward.lsp.servers[pair[3]] == nil, "basic server survived alternate stack")
  assert(forward.lsp.servers[pair[4]], "alternate server was not registered")

  -- Even an empty explicitly configured server must not be discarded.
  for _, ids in ipairs({ { pair[1], pair[2] }, { pair[2], pair[1] } }) do
    local explicit = config()
    explicit.lsp.servers[pair[3]] = {}
    apply(ids, explicit)
    assert(explicit.lsp.servers[pair[3]], "explicit user server was removed")
  end

  -- Overrides made to an active extra's defaults belong to the user as well.
  local changed = apply({ pair[1] })
  changed.lsp.servers[pair[3]].settings = { custom = true }
  apply({ pair[2] }, changed)
  assert(changed.lsp.servers[pair[3]].settings.custom, "edited server config was removed")
  local fresh = apply({ pair[1] })
  assert(
    vim.tbl_get(fresh.lsp.servers[pair[3]], "settings", "custom") == nil,
    "editing a live server leaked into the extra's defaults"
  )
end

local standard = apply({ "lang.typescript" })
assert(standard.lsp.servers.tsc, "the standard TypeScript extra did not enable native tsc")
assert(standard.lsp.servers.ts_ls == nil, "the standard TypeScript extra enabled the legacy server")
assert(
  standard.lsp.servers.tsgo == nil,
  "the standard TypeScript extra enabled the deprecated alias"
)
local legacy = apply({ "lang.typescript-legacy" })
assert(legacy.lsp.servers.ts_ls.before_init, "legacy TypeScript lost its SDK initialization hook")
assert(legacy.lsp.servers.tsc == nil, "legacy TypeScript unexpectedly enabled native tsc")

-- The old saved ID resolves to the same stack and contributes nothing twice.
for _, ids in ipairs({
  { "lang.typescript-tsgo" },
  { "lang.typescript", "lang.typescript-tsgo" },
  { "lang.typescript-tsgo", "lang.typescript" },
  { "lang.typescript-legacy", "lang.typescript-tsgo", "lang.typescript" },
  { "lang.typescript-tsgo", "lang.typescript-legacy", "lang.typescript" },
  { "lang.typescript", "lang.typescript-tsgo", "lang.typescript-legacy" },
}) do
  local aliased = apply(ids)
  for _, field in ipairs({ "lsp", "format", "lint", "mason", "treesitter" }) do
    assert(
      vim.deep_equal(standard[field], aliased[field]),
      "TypeScript compatibility alias changed " .. field
    )
  end
end

local python = apply({ "lang.python" })
assert(python.lsp.servers.ruff, "Python lost Ruff LSP diagnostics")
assert(python.lint.linters_by_ft.python == nil, "Python still runs Ruff twice")

for _, ids in ipairs({
  { "lang.python", "lang.python-pro" },
  { "lang.python-pro", "lang.python" },
}) do
  local explicit = config()
  explicit.format.formatters_by_ft.python = { "isort", "black" }
  explicit.lint.linters_by_ft.python = { "ruff" }
  apply(ids, explicit)
  assert(
    vim.deep_equal(explicit.format.formatters_by_ft.python, { "isort", "black" }),
    "explicit formatters were replaced"
  )
  assert(
    vim.deep_equal(explicit.lint.linters_by_ft.python, { "ruff" }),
    "explicit lint config was removed"
  )
end

local native = config()
local before_init = function() end
native.lsp.servers.tsgo = {
  cmd = { "custom-tsc", "--lsp", "--stdio" },
  before_init = before_init,
  settings = { ["js/ts"] = { inlayHints = { parameterTypes = { enabled = false } } } },
}
native.lsp.servers.tsc = {
  settings = { ["js/ts"] = { inlayHints = { parameterTypes = { enabled = true } } } },
}
apply({ "lang.typescript-tsgo" }, native)
assert(native.lsp.servers.tsgo == nil, "deprecated tsgo server remained enabled")
assert(native.lsp.servers.tsc.cmd[1] == "custom-tsc", "legacy command override was lost")
assert(native.lsp.servers.tsc.before_init == before_init, "legacy hook override was lost")
assert(
  native.lsp.servers.tsc.settings["js/ts"].inlayHints.parameterTypes.enabled,
  "explicit tsc setting lost precedence"
)

-- An unrelated stack must not silently migrate a manually configured server.
local manual = config()
manual.lsp.servers.tsgo = { cmd = { "manual-tsgo" } }
apply({ "lang.typescript-legacy" }, manual)
assert(manual.lsp.servers.tsgo.cmd[1] == "manual-tsgo")

-- Exercise the live activation entrypoint while keeping installs out of this
-- focused test. Runtime refresh must receive the same effective server set.
local saved = {}
local refreshed_servers
local refresh_count = 0
for name, substitute in pairs({
  ["blak.lazy"] = { refresh = function() end },
  ["blak.core.lsp"] = {
    enable = function(value)
      refresh_count = refresh_count + 1
      refreshed_servers = vim.deepcopy(value.lsp.servers)
    end,
  },
  ["blak.core.formatting"] = { refresh = function() end },
  ["blak.core.keymaps"] = { apply_extra = function() end },
  ["blak.core.treesitter"] = { install = function() end },
  ["blak.core.tools"] = { ensure = function() end },
}) do
  saved[name] = package.loaded[name] or false
  package.loaded[name] = substitute
end
for _, ids in ipairs({
  { "lang.python-pro", "lang.python", "basedpyright", "pyright" },
  { "lang.typescript", "lang.typescript-legacy", "tsc", "ts_ls" },
  { "lang.typescript-tsgo", "lang.typescript-legacy", "tsc", "ts_ls" },
}) do
  local live = config()
  assert(extras.activate(ids[1], live))
  assert(extras.activate(ids[2], live))
  assert(refreshed_servers[ids[3]], "live activation lost the selected alternate server")
  assert(refreshed_servers[ids[4]] == nil, "live activation revived the basic server")
end
for _, ids in ipairs({
  { "lang.typescript", "lang.typescript-tsgo" },
  { "lang.typescript-tsgo", "lang.typescript" },
}) do
  refresh_count = 0
  local live = config()
  assert(extras.activate(ids[1], live))
  assert(not extras.activate(ids[2], live), "an active alias reapplied the native stack")
  assert(refresh_count == 1, "native TypeScript was set up twice through its alias")
end
local migrated_live = config()
migrated_live.lsp.servers.tsgo = { cmd = { "custom-native", "--lsp", "--stdio" } }
extras.activate("lang.typescript", migrated_live)
assert(
  extras.activate("lang.typescript-tsgo", migrated_live),
  "legacy settings did not refresh an active native stack"
)
assert(refreshed_servers.tsgo == nil, "live alias migration left tsgo enabled")
assert(
  refreshed_servers.tsc.cmd[1] == "custom-native",
  "live alias migration lost the command override"
)
for name, value in pairs(saved) do
  package.loaded[name] = value or nil
end

print("Language stack smoke passed")
