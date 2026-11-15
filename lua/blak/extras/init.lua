local M = {}
local extras_view = require("blak.extras_view")

local modules = {
  "blak.extras.lang.lua",
  "blak.extras.lang.typescript",
  "blak.extras.lang.typescript_legacy",
  "blak.extras.lang.typescript_tsgo",
  "blak.extras.lang.python",
  "blak.extras.lang.python_pro",
  "blak.extras.lang.rust",
  "blak.extras.lang.go",
  "blak.extras.lang.markdown",
  "blak.extras.lang.c",
  "blak.extras.lang.bash",
  "blak.extras.lang.zig",
  "blak.extras.lang.nix",
  "blak.extras.lang.terraform",
  "blak.extras.lang.web",
  "blak.extras.lang.tailwind",
  "blak.extras.lang.docker",
  "blak.extras.lang.yaml",
  "blak.extras.lang.json",
  "blak.extras.debug.dap",
  "blak.extras.test.neotest",
  "blak.extras.ui.animations",
  "blak.extras.ui.base46",
  "blak.extras.ui.comfy_line_numbers",
  "blak.extras.ui.dim",
  "blak.extras.ui.image_preview",
  "blak.extras.ui.lualine",
  "blak.extras.ui.zen",
  "blak.extras.ui.indent",
  "blak.extras.git.lazygit",
  "blak.extras.git.diffview",
  "blak.extras.git.gitbrowse",
  "blak.extras.git.neogit",
  "blak.extras.ai.claudecode",
  "blak.extras.ai.copilot",
  "blak.extras.ai.sidekick",
  "blak.extras.editor.aerial",
  "blak.extras.editor.harpoon",
  "blak.extras.editor.mini",
  "blak.extras.editor.overseer",
  "blak.extras.editor.refactoring",
  "blak.extras.editor.render_markdown",
  "blak.extras.editor.todo_comments",
  "blak.extras.editor.trouble",
  "blak.extras.editor.window_navigation",
  "blak.extras.editor.neotree",
  "blak.extras.editor.snacks_explorer",
  "blak.extras.editor.snacks_terminal",
  "blak.extras.editor.telescope",
  "blak.extras.editor.fzf_lua",
  "blak.extras.editor.scratch",
  "blak.extras.editor.grug_far",
  "blak.extras.editor.flash",
  "blak.extras.editor.emmet",
}

local registry_cache

-- Extras that no longer exist, and what to tell anyone who still enables one.
local removed = {
  ["ai.supermaven"] = "ai.supermaven was removed because the Supermaven service shut down. "
    .. "Use ai.copilot for inline suggestions.",
}

function M.removed(id)
  return removed[id]
end

local function registry()
  if registry_cache then
    return registry_cache
  end
  registry_cache = {}
  for _, module in ipairs(modules) do
    local extra = require(module)
    registry_cache[extra.id] = extra
  end
  return registry_cache
end

local function merge_missing_by_ft(target, source, contributed)
  for ft, value in pairs(source or {}) do
    if target[ft] == nil then
      target[ft] = vim.deepcopy(value)
      if contributed then
        contributed[ft] = vim.deepcopy(value)
      end
    end
  end
end

-- Alternate language stacks replace only defaults supplied by the basic
-- extra. Explicit user servers and formatter/linter lists remain untouched.
local function language_fields(config)
  return {
    servers = config.lsp.servers,
    formatters = config.format.formatters_by_ft,
    linters = config.lint.linters_by_ft,
  }
end

local function supersede(config, id)
  local fields = language_fields(config)
  local contributed = config._extra_language_defaults[id] or {}
  for field, values in pairs(contributed) do
    for key, value in pairs(values) do
      if vim.deep_equal(fields[field][key], value) then
        fields[field][key] = nil
      end
    end
  end
  config._extra_language_defaults[id] = nil
end

local function is_superseded(config, id)
  for applied in pairs(config._extra_applied) do
    if vim.tbl_contains(registry()[applied].supersedes or {}, id) then
      return true
    end
  end
  return false
end

local function contains(list, needle)
  for _, value in ipairs(list or {}) do
    if value == needle then
      return true
    end
  end
  return false
end

local function refresh_snacks(extra, config)
  if not extra.snacks then
    return
  end

  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.config then
    return
  end

  for name in pairs(extra.snacks) do
    local opts = config.snacks[name]
    snacks.config[name] = vim.tbl_deep_extend("force", snacks.config[name] or {}, opts)
    if opts.enabled ~= false then
      local ok_module, module = pcall(function()
        return snacks[name]
      end)
      if ok_module then
        if module.enable then
          pcall(module.enable)
        elseif module.setup and (name == "image" or vim.tbl_get(module, "meta", "needs_setup")) then
          pcall(module.setup)
        end
      end
    end
  end
end

local function refresh_runtime(config, extra, integrations)
  require("blak.lazy").refresh(config)

  if extra.lsp and extra.lsp.servers then
    require("blak.core.lsp").enable(config)
  end

  if extra.format or extra.lint then
    require("blak.core.formatting").refresh(config)
  end

  local needs_tools = extra.mason ~= nil
  for _, part in ipairs({ extra, unpack(integrations or {}) }) do
    if part.keys then
      require("blak.core.keymaps").apply_extra(part.keys)
    end
    needs_tools = needs_tools or part.mason ~= nil
  end

  refresh_snacks(extra, config)

  if extra.treesitter then
    require("blak.core.treesitter").install(config)
  end
  if needs_tools and config.mason.automatic_install then
    require("blak.core.tools").ensure(config)
  end
end

function M.enabled(config)
  local util = require("blak.util")
  local state = require("blak.extras.state").read()
  return util.unique(vim.list_extend(vim.deepcopy(config.extras.enabled or {}), state))
end

function M.is_known(id)
  return registry()[id] ~= nil
end

local function merge_parts(config, part)
  local util = require("blak.util")
  config.mason.ensure_installed = util.extend_list(config.mason.ensure_installed, part.mason)
  if part.keys then
    vim.list_extend(config._extra_keymaps, vim.deepcopy(part.keys))
  end
  if part.plugins then
    vim.list_extend(config._extra_plugin_specs, vim.deepcopy(part.plugins))
  end
end

-- An extra's `integrations` table holds what it adds only when another extra
-- is enabled too, such as Delve and neotest-golang for lang.go with debug.dap
-- or test.neotest. Apply every pair that `id` completes, in either direction.
local function apply_integrations(config, id)
  config._extra_integrations = config._extra_integrations or {}
  local applied = {}
  local function apply_pair(owner, target)
    local part = vim.tbl_get(registry(), owner, "integrations", target)
    local key = owner .. ">" .. target
    if part and not config._extra_integrations[key] then
      config._extra_integrations[key] = true
      merge_parts(config, part)
      table.insert(applied, part)
    end
  end
  for target in pairs(registry()[id].integrations or {}) do
    if config._extra_applied[target] then
      apply_pair(id, target)
    end
  end
  for owner in pairs(config._extra_applied) do
    if owner ~= id then
      apply_pair(owner, id)
    end
  end
  return applied
end

function M.apply_one(config, id)
  local util = require("blak.util")
  config._extra_plugin_specs = config._extra_plugin_specs or {}
  config._extra_keymaps = config._extra_keymaps or {}
  config._extra_applied = config._extra_applied or {}
  config._extra_language_defaults = config._extra_language_defaults or {}

  if config._extra_applied[id] then
    return nil
  end

  local extra = registry()[id]
  if not extra then
    util.warn(
      (removed[id] or ("Unknown Blak extra: " .. id))
        .. " Run :BlakExtras disable "
        .. id
        .. " or remove it from extras.enabled in user.lua."
    )
    return nil
  end

  if extra.alias then
    local changed = extra.apply and extra.apply(config)
    local applied = M.apply_one(config, extra.alias)
    config._extra_applied[id] = true
    -- Refresh an existing canonical stack only if legacy settings were moved.
    return applied or (changed and registry()[extra.alias] or nil)
  end

  for _, replaced in ipairs(extra.supersedes or {}) do
    supersede(config, replaced)
  end
  if extra.apply then
    extra.apply(config)
  end
  config.treesitter.ensure_installed =
    util.extend_list(config.treesitter.ensure_installed, extra.treesitter)
  config.mason.ensure_installed = util.extend_list(config.mason.ensure_installed, extra.mason)
  if not is_superseded(config, id) then
    local contributed = { servers = {}, formatters = {}, linters = {} }
    config._extra_language_defaults[id] = contributed
    if extra.lsp and extra.lsp.servers then
      for name, server in pairs(extra.lsp.servers) do
        if config.lsp.servers[name] == nil then
          contributed.servers[name] = vim.deepcopy(server)
        end
      end
      config.lsp.servers =
        vim.tbl_deep_extend("keep", config.lsp.servers or {}, vim.deepcopy(extra.lsp.servers))
    end
    if extra.format and extra.format.formatters_by_ft then
      merge_missing_by_ft(
        config.format.formatters_by_ft,
        extra.format.formatters_by_ft,
        contributed.formatters
      )
    end
    if extra.lint and extra.lint.linters_by_ft then
      merge_missing_by_ft(config.lint.linters_by_ft, extra.lint.linters_by_ft, contributed.linters)
    end
  end
  if extra.snacks then
    config.snacks = vim.tbl_deep_extend("keep", config.snacks or {}, vim.deepcopy(extra.snacks))
  end
  if extra.keys then
    vim.list_extend(config._extra_keymaps, vim.deepcopy(extra.keys))
  end
  if extra.plugins then
    local specs = type(extra.plugins) == "function" and extra.plugins(config) or extra.plugins
    vim.list_extend(config._extra_plugin_specs, specs or {})
  end

  config._extra_applied[id] = true
  config._extra_new_integrations = apply_integrations(config, id)
  return extra
end

function M.apply(config)
  config._extra_plugin_specs = config._extra_plugin_specs or {}
  config._extra_keymaps = config._extra_keymaps or {}
  config._extra_applied = config._extra_applied or {}

  for _, id in ipairs(M.enabled(config)) do
    M.apply_one(config, id)
  end
end

function M.activate(id, config)
  config = config or require("blak.config").get()
  local extra = M.apply_one(config, id)
  if extra then
    refresh_runtime(config, extra, config._extra_new_integrations)
  end
  return extra ~= nil
end

function M.all()
  local out = {}
  for _, id in ipairs(require("blak.util").tbl_keys(registry())) do
    table.insert(out, registry()[id])
  end
  return out
end

function M.get(id)
  return registry()[id]
end

function M.set_enabled(action, id, config, opts)
  opts = opts or {}
  if opts.notify == nil then
    opts.notify = true
  end

  local util = require("blak.util")
  config = config or require("blak.config").get()
  config.extras = config.extras or { enabled = {} }

  if not id then
    if opts.notify then
      util.warn("Unknown extra: " .. tostring(id))
    end
    return false
  end

  if action == "enable" or action == "disable" then
    local current = require("blak.extras.state").read()
    local known = M.is_known(id)
    if action == "enable" and not known then
      if opts.notify then
        util.warn("Unknown extra: " .. id)
      end
      return false
    end
    if
      action == "disable"
      and not known
      and not contains(current, id)
      and not contains(config.extras.enabled or {}, id)
    then
      if opts.notify then
        util.warn("Unknown extra: " .. id)
      end
      return false
    end

    local next_ids = {}
    local found = false
    for _, current_id in ipairs(current) do
      if current_id == id then
        found = true
        if action == "enable" then
          table.insert(next_ids, current_id)
        end
      else
        table.insert(next_ids, current_id)
      end
    end
    if action == "enable" and not found then
      table.insert(next_ids, id)
    end
    require("blak.extras.state").write(next_ids)
    if action == "disable" and contains(config.extras.enabled or {}, id) then
      if opts.notify then
        util.warn(id .. " is still enabled in lua/blak/user.lua. Remove it there to disable it.")
      end
      return false
    end

    local active
    if action == "enable" then
      active = M.activate(id, config)
    end

    if opts.notify then
      if action == "disable" and not known then
        util.notify(
          "Removed stale extra "
            .. id
            .. " from state. Run :restart, then :BlakExtras sync if plugins changed."
        )
      elseif action == "enable" then
        local suffix = active and " Applied to this session." or " Already active in this session."
        -- Integrations completed by this extra can add plugins of their own.
        local adds_plugins = registry()[id].plugins ~= nil
          or vim.iter(active and config._extra_new_integrations or {}):any(function(part)
            return part.plugins ~= nil
          end)
        if adds_plugins then
          suffix = suffix .. " Run :BlakExtras sync if plugins need installing."
        end
        util.notify("Enabled " .. id .. "." .. suffix)
      else
        util.notify(
          "Disabled "
            .. id
            .. ". Run :restart to unload it, then :BlakExtras sync to remove unused plugins."
        )
      end
    end
    return true
  end

  if opts.notify then
    util.warn("Unknown BlakExtras action: " .. tostring(action))
  end
  return false
end

function M.toggle(id, config, opts)
  config = config or require("blak.config").get()
  local enabled = contains(M.enabled(config), id)
  return M.set_enabled(enabled and "disable" or "enable", id, config, opts)
end

-- Install missing plugins at their pinned commits and remove plugins no spec
-- uses. Unlike :Lazy sync this never moves an installed plugin; updates stay
-- behind :BlakUpdate and its channel and migration checks.
function M.sync()
  local lazy = require("lazy")
  lazy.clean({ show = false, wait = true })
  -- Every lazy.nvim lockfile write, including the clean above, drops entries
  -- for plugins that are not installed yet; restore their shipped pins.
  require("blak.lazy").seed_lockfile()
  lazy.install({ clear = false, lockfile = true })
end

function M.command(opts)
  local util = require("blak.util")
  local args = vim.split(opts.args or "", "%s+", { trimempty = true })
  local action, id = args[1], args[2]
  local config = require("blak.config").get()

  if not action or action == "list" then
    extras_view.open(config)
    return
  end

  if action == "enable" or action == "disable" then
    M.set_enabled(action, id, config)
    return
  end

  if action == "sync" then
    M.sync()
    return
  end

  util.warn("Unknown BlakExtras action: " .. action)
end

local function complete_filter(values, prefix)
  prefix = prefix or ""
  local out = {}
  for _, value in ipairs(values) do
    if prefix == "" or value:sub(1, #prefix) == prefix then
      table.insert(out, value)
    end
  end
  return out
end

function M.complete(arglead, line)
  line = line or ""
  local args = vim.split(line, "%s+", { trimempty = true })
  local command = args[1] and args[1]:gsub("^:", "")
  if command and vim.tbl_contains({ "BlakExtras", "BlackExtras" }, command) then
    table.remove(args, 1)
  end

  local actions = { "list", "enable", "disable", "sync" }
  local completing_action = #args == 0 or (#args == 1 and not line:match("%s$"))
  if completing_action then
    return complete_filter(actions, arglead)
  end

  if args[1] == "enable" or args[1] == "disable" then
    return complete_filter(require("blak.util").tbl_keys(registry()), arglead)
  end
  return {}
end

return M
