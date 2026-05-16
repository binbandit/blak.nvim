local M = {}

local modules = {
  "blak.extras.lang.lua",
  "blak.extras.lang.typescript",
  "blak.extras.lang.python",
  "blak.extras.lang.rust",
  "blak.extras.lang.go",
  "blak.extras.lang.markdown",
  "blak.extras.ui.animations",
  "blak.extras.ui.image_preview",
  "blak.extras.ui.zen",
  "blak.extras.git.lazygit",
  "blak.extras.git.diffview",
  "blak.extras.ai.copilot",
  "blak.extras.editor.neotree",
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

local function merge_formatters(target, source)
  for ft, value in pairs(source or {}) do
    target[ft] = value
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

function M.enabled(config)
  local util = require("blak.util")
  local state = require("blak.extras.state").read()
  return util.unique(vim.list_extend(vim.deepcopy(config.extras.enabled or {}), state))
end

function M.apply(config)
  local util = require("blak.util")
  config._extra_plugin_specs = config._extra_plugin_specs or {}
  config._extra_keymaps = config._extra_keymaps or {}

  for _, id in ipairs(M.enabled(config)) do
    local extra = registry()[id]
    if extra then
      if extra.apply then
        extra.apply(config)
      end
      config.treesitter.ensure_installed = util.extend_list(config.treesitter.ensure_installed, extra.treesitter)
      config.mason.ensure_installed = util.extend_list(config.mason.ensure_installed, extra.mason)
      if extra.lsp and extra.lsp.servers then
        config.lsp.servers = vim.tbl_deep_extend("force", config.lsp.servers or {}, extra.lsp.servers)
      end
      if extra.format and extra.format.formatters_by_ft then
        merge_formatters(config.format.formatters_by_ft, extra.format.formatters_by_ft)
      end
      if extra.lint and extra.lint.linters_by_ft then
        merge_formatters(config.lint.linters_by_ft, extra.lint.linters_by_ft)
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
    else
      util.warn("Unknown Blak extra: " .. id)
    end
  end
end

local function lines(config)
  local enabled_lookup = {}
  for _, id in ipairs(M.enabled(config or require("blak.config").get())) do
    enabled_lookup[id] = true
  end

  local out = { "# Blak extras", "", "Use :BlakExtras enable <id> or :BlakExtras disable <id>.", "" }
  local ids = require("blak.util").tbl_keys(registry())
  for _, id in ipairs(ids) do
    local extra = registry()[id]
    local mark = enabled_lookup[id] and "●" or "○"
    table.insert(out, string.format("%s %-26s %s", mark, id, extra.description or extra.label or ""))
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
    if not id or not registry()[id] then
      util.warn("Unknown extra: " .. tostring(id))
      return
    end
    local current = require("blak.extras.state").read()
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
    util.notify((action == "enable" and "Enabled " or "Disabled ") .. id .. ". Restart Blak, then run :Lazy sync if plugins changed.")
    return
  end

  if action == "sync" then
    vim.cmd("Lazy sync")
    return
  end

  util.warn("Unknown BlakExtras action: " .. action)
end

function M.complete(line)
  local args = vim.split(line, "%s+", { trimempty = true })
  if #args <= 1 then
    return { "list", "enable", "disable", "sync" }
  end
  if args[2] == "enable" or args[2] == "disable" then
    return require("blak.util").tbl_keys(registry())
  end
  return {}
end

return M
