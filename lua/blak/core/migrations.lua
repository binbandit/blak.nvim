local M = {}

-- Add a migration here whenever a shipped default changes, together with a
-- NEWS.md entry. A breaking migration blocks :BlakUpdate and only runs
-- through :BlakUpgrade; non-breaking migrations run on the next :BlakUpgrade.
local migrations = {
  {
    id = "v0.2.1.autopairs",
    description = "Core pair handling moved from mini.pairs to nvim-autopairs in v0.2.1",
    apply = function(_, context)
      context.util.notify(
        "Since v0.2.1 core pair handling uses nvim-autopairs instead of mini.pairs (see NEWS.md). "
          .. 'To opt out, add { "windwp/nvim-autopairs", enabled = false } to plugins.specs '
          .. "and wire your preferred pairs plugin there too."
      )
    end,
  },
  {
    id = "v0.3.1.eslint_d",
    description = "lang.typescript and lang.typescript-tsgo dropped eslint_d; the ESLint language server covers it",
    apply = function(config, context)
      -- Read through blak.extras so extras enabled with :BlakExtras (state file)
      -- are covered, not just the ones listed in user.lua.
      local enabled = require("blak.extras").enabled(config)
      local uses_typescript = vim.tbl_contains(enabled, "lang.typescript")
        or vim.tbl_contains(enabled, "lang.typescript-tsgo")
      if not uses_typescript then
        return
      end

      context.util.notify(
        "The TypeScript extras no longer run eslint_d; the ESLint language server already provides "
          .. "ESLint diagnostics without the duplicate spawns and parse errors (see NEWS.md). "
          .. 'To keep eslint_d, add lint = { linters_by_ft = { typescript = { "eslint_d" } } } '
          .. "to your Blak config for the filetypes you want."
      )
    end,
  },
  {
    id = "v0.3.1.copilot_suggestions",
    description = "ai.copilot now shows inline suggestions instead of loading a plugin with every surface disabled",
    apply = function(config, context)
      if not vim.tbl_contains(require("blak.extras").enabled(config), "ai.copilot") then
        return
      end

      context.util.notify(
        "ai.copilot now turns on inline suggestions; before this it installed copilot.lua with the "
          .. "suggestion and panel surfaces disabled, so an authenticated Copilot produced nothing "
          .. "(see NEWS.md). Accept with <M-l>, accept a word with <M-w>, cycle with <M-]> and <M-[>, "
          .. "dismiss with <C-]>, and toggle auto trigger with <leader>ag. blink.cmp's inline preview "
          .. "now yields while a Copilot suggestion is on screen. "
          .. "To go back, set ai = { copilot = { suggestion = { enabled = false } } }."
      )
    end,
  },
}

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
