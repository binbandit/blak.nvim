local M = {}

local modules = {
  "blak.extras.lang.lua",
  "blak.extras.lang.typescript",
  "blak.extras.lang.typescript_tsgo",
  "blak.extras.lang.python",
  "blak.extras.lang.rust",
  "blak.extras.lang.go",
  "blak.extras.lang.markdown",
  "blak.extras.ui.animations",
  "blak.extras.ui.base46",
  "blak.extras.ui.image_preview",
  "blak.extras.ui.zen",
  "blak.extras.git.lazygit",
  "blak.extras.git.diffview",
  "blak.extras.ai.copilot",
  "blak.extras.editor.neotree",
  "blak.extras.editor.snacks_explorer",
  "blak.extras.editor.telescope",
  "blak.extras.editor.fzf_lua",
}

local registry_cache

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

local function merge_missing_by_ft(target, source)
  for ft, value in pairs(source or {}) do
    if target[ft] == nil then
      target[ft] = value
    end
  end
end

local function contains(list, needle)
  for _, value in ipairs(list or {}) do
    if value == needle then
      return true
    end
  end
  return false
end

local function lsp_server_names(extra)
  local out = {}
  for name in pairs(vim.tbl_get(extra, "lsp", "servers") or {}) do
    table.insert(out, name)
  end
  return out
end

local function refresh_lazy_specs(config, extra)
  if not extra.plugins or not package.loaded["lazy.core.config"] then
    return
  end

  local ok, err = pcall(function()
    local lazy_config = require("lazy.core.config")
    lazy_config.options.spec = require("blak.plugins").specs(config)
    require("lazy.core.plugin").load()
    require("lazy.core.handler").setup()
    vim.api.nvim_exec_autocmds("User", { pattern = "LazyRender", modeline = false })
    vim.api.nvim_exec_autocmds("User", { pattern = "LazyReload", modeline = false })
  end)
  if not ok then
    require("blak.util").warn("Could not refresh lazy.nvim specs: " .. tostring(err))
  end
end

local function refresh_snacks(extra)
  if not extra.snacks then
    return
  end

  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.config then
    return
  end

  for name, opts in pairs(extra.snacks) do
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

local function refresh_runtime(config, extra)
  if extra.lsp and extra.lsp.servers then
    require("blak.core.lsp").enable(config, lsp_server_names(extra))
  end

  if extra.format or extra.lint then
    require("blak.core.formatting").refresh(config)
  end

  if extra.keys then
    require("blak.core.keymaps").apply_extra(extra.keys)
  end

  refresh_snacks(extra)
  refresh_lazy_specs(config, extra)

  if extra.treesitter then
    require("blak.core.treesitter").install(config)
  end
  if extra.mason and config.mason.automatic_install then
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

function M.apply_one(config, id)
  local util = require("blak.util")
  config._extra_plugin_specs = config._extra_plugin_specs or {}
  config._extra_keymaps = config._extra_keymaps or {}
  config._extra_applied = config._extra_applied or {}

  if config._extra_applied[id] then
    return nil
  end

  local extra = registry()[id]
  if not extra then
    util.warn("Unknown Blak extra: " .. id)
    return nil
  end

  if extra.apply then
    extra.apply(config)
  end
  config.treesitter.ensure_installed = util.extend_list(config.treesitter.ensure_installed, extra.treesitter)
  config.mason.ensure_installed = util.extend_list(config.mason.ensure_installed, extra.mason)
  if extra.lsp and extra.lsp.servers then
    config.lsp.servers = vim.tbl_deep_extend("force", config.lsp.servers or {}, extra.lsp.servers)
  end
  if extra.format and extra.format.formatters_by_ft then
    merge_missing_by_ft(config.format.formatters_by_ft, extra.format.formatters_by_ft)
  end
  if extra.lint and extra.lint.linters_by_ft then
    merge_missing_by_ft(config.lint.linters_by_ft, extra.lint.linters_by_ft)
  end
  if extra.snacks then
    config.snacks = vim.tbl_deep_extend("force", config.snacks or {}, extra.snacks)
  end
  if extra.keys then
    vim.list_extend(config._extra_keymaps, extra.keys)
  end
  if extra.plugins then
    local specs = type(extra.plugins) == "function" and extra.plugins(config) or extra.plugins
    vim.list_extend(config._extra_plugin_specs, specs or {})
  end

  config._extra_applied[id] = true
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
    refresh_runtime(config, extra)
  end
  return extra ~= nil
end

local function lines(config)
  local enabled_lookup = {}
  for _, id in ipairs(M.enabled(config or require("blak.config").get())) do
    enabled_lookup[id] = true
  end

  local out = { "# Blak extras", "", "Use :BlakExtras enable <id> or :BlakExtras disable <id>. :BlackExtras also works.", "" }
  local ids = require("blak.util").tbl_keys(registry())
  for _, id in ipairs(ids) do
    local extra = registry()[id]
    local mark = enabled_lookup[id] and "●" or "○"
    table.insert(out, string.format("%s %-26s %s", mark, id, extra.description or extra.label or ""))
  end
  for _, id in ipairs(require("blak.util").tbl_keys(enabled_lookup)) do
    if not M.is_known(id) then
      table.insert(out, string.format("! %-26s Unknown extra; disable it to remove stale state", id))
    end
  end
  return out
end

function M.command(opts)
  local util = require("blak.util")
  local args = vim.split(opts.args or "", "%s+", { trimempty = true })
  local action, id = args[1], args[2]
  local config = require("blak.config").get()

  if not action or action == "list" then
    util.open_scratch("Blak extras", lines(config))
    return
  end

  if action == "enable" or action == "disable" then
    if not id then
      util.warn("Unknown extra: " .. tostring(id))
      return
    end
    local current = require("blak.extras.state").read()
    local known = M.is_known(id)
    if action == "enable" and not known then
      util.warn("Unknown extra: " .. id)
      return
    end
    if action == "disable" and not known and not contains(current, id) and not contains(config.extras.enabled, id) then
      util.warn("Unknown extra: " .. id)
      return
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
    if action == "disable" and contains(config.extras.enabled, id) then
      util.warn(id .. " is still enabled in lua/blak/user.lua. Remove it there to disable it.")
      return
    end
    if action == "disable" and not known then
      util.notify("Removed stale extra " .. id .. " from state. Restart Blak, then run :Lazy sync if plugins changed.")
    elseif action == "enable" then
      local active = M.activate(id, config)
      local suffix = active and " Applied to this session." or " Already active in this session."
      if registry()[id].plugins then
        suffix = suffix .. " Run :BlakExtras sync if plugins need installing."
      end
      util.notify("Enabled " .. id .. "." .. suffix)
    else
      util.notify("Disabled " .. id .. ". Restart Blak to unload anything already active, then run :Lazy sync if plugins changed.")
    end
    return
  end

  if action == "sync" then
    vim.cmd("Lazy sync")
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
