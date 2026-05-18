local M = {}

local valid_channels = { stable = true, edge = true, nightly = true }
local valid_pickers = { fff = true, snacks = true, telescope = true, fzf_lua = true }
local valid_explorers = { oil = true, snacks = true }
local valid_terminals = { native = true, snacks = true }
local valid_mini_module = "^[%w_%-]+$"

local function kind(value)
  if type(value) ~= "table" then
    return type(value)
  end
  return "table"
end

local function expect(errors, path, value, expected)
  if type(value) ~= expected then
    table.insert(errors, string.format("%s must be %s, got %s", path, expected, kind(value)))
    return false
  end
  return true
end

local function validate_mode(errors, path, mode)
  if mode == nil then
    return
  end
  if type(mode) == "string" then
    return
  end
  if type(mode) == "table" then
    for _, item in ipairs(mode) do
      if type(item) ~= "string" then
        table.insert(errors, path .. " entries must be strings")
        return
      end
    end
    return
  end
  table.insert(errors, path .. " must be a string or list of strings")
end

local function validate_keymap(errors, index, item)
  local path = "keymaps[" .. index .. "]"
  if type(item) ~= "table" then
    table.insert(errors, path .. " must be a table")
    return
  end

  local key = item.key or item.lhs
  if type(key) ~= "string" then
    table.insert(errors, path .. ".key must be a string")
  end
  validate_mode(errors, path .. ".mode", item.mode)

  if item.disable ~= nil then
    expect(errors, path .. ".disable", item.disable, "boolean")
  end

  local action = item.action
  if action == nil then
    action = item.rhs
  end

  if item.disable == true or action == false then
    return
  end
  if type(action) ~= "string" and type(action) ~= "function" then
    table.insert(errors, path .. ".action must be string, function, or false")
  end
  local description = item.description or item.desc
  if type(description) ~= "string" or description == "" then
    table.insert(errors, path .. ".description must be a non-empty string")
  end
  if item.opts ~= nil then
    expect(errors, path .. ".opts", item.opts, "table")
  end
end

local function validate_plugin_specs(errors, config)
  if config.plugins == nil then
    return
  end
  if not expect(errors, "plugins", config.plugins, "table") then
    return
  end
  if config.plugins.specs == nil then
    return
  end
  if not expect(errors, "plugins.specs", config.plugins.specs, "table") then
    return
  end
  for key, spec in pairs(config.plugins.specs) do
    if type(key) ~= "number" then
      table.insert(errors, "plugins.specs must be a list")
      break
    end
    local spec_type = type(spec)
    if spec_type ~= "string" and spec_type ~= "table" then
      table.insert(errors, "plugins.specs entries must be lazy.nvim specs")
      break
    end
  end
end

local function validate_hook(errors, phase, hook)
  if hook == nil then
    return
  end
  local path = "hooks." .. phase
  if type(hook) == "function" then
    return
  end
  if type(hook) ~= "table" then
    table.insert(errors, path .. " must be a function or list of functions")
    return
  end
  for key, item in pairs(hook) do
    if type(key) ~= "number" then
      table.insert(errors, path .. " must be a list")
      return
    end
    if type(item) ~= "function" then
      table.insert(errors, path .. " entries must be functions")
      return
    end
  end
end

local function validate_hooks(errors, config)
  if config.hooks == nil then
    return
  end
  if not expect(errors, "hooks", config.hooks, "table") then
    return
  end
  validate_hook(errors, "before", config.hooks.before)
  validate_hook(errors, "after", config.hooks.after)
end

local function validate_ui(errors, config)
  if config.ui == nil then
    return
  end
  if config.ui.colorscheme ~= nil then
    expect(errors, "ui.colorscheme", config.ui.colorscheme, "string")
  end
  if config.ui.transparent ~= nil then
    expect(errors, "ui.transparent", config.ui.transparent, "boolean")
  end
  if config.ui.theme ~= nil then
    expect(errors, "ui.theme", config.ui.theme, "table")
  end
end

function M.validate(config)
  local errors = {}

  expect(errors, "leader", config.leader, "string")
  expect(errors, "localleader", config.localleader, "string")
  local has_package = expect(errors, "package", config.package, "table")
  expect(errors, "ui", config.ui, "table")
  local has_completion = expect(errors, "completion", config.completion, "table")
  local has_picker = expect(errors, "picker", config.picker, "table")
  local has_explorer = expect(errors, "explorer", config.explorer, "table")
  local has_terminal = expect(errors, "terminal", config.terminal, "table")
  local has_keymaps = expect(errors, "keymaps", config.keymaps, "table")
  local has_ai = expect(errors, "ai", config.ai, "table")
  local has_mini = expect(errors, "mini", config.mini, "table")
  expect(errors, "lsp", config.lsp, "table")
  local has_extras = expect(errors, "extras", config.extras, "table")

  if has_package and not valid_channels[config.package.channel] then
    table.insert(errors, "package.channel must be stable, edge, or nightly")
  end

  validate_ui(errors, config)

  if has_picker and not valid_pickers[config.picker.provider] then
    table.insert(errors, "picker.provider must be fff, snacks, telescope, or fzf_lua")
  end

  if has_completion and config.completion.super_tab ~= nil then
    expect(errors, "completion.super_tab", config.completion.super_tab, "boolean")
  end

  if has_explorer and not valid_explorers[config.explorer.provider] then
    table.insert(errors, "explorer.provider must be oil or snacks")
  end

  if has_terminal then
    if not valid_terminals[config.terminal.provider] then
      table.insert(errors, "terminal.provider must be native or snacks")
    end
    if config.terminal.toggle_key ~= false and config.terminal.toggle_key ~= nil then
      expect(errors, "terminal.toggle_key", config.terminal.toggle_key, "string")
    end
  end

  if has_keymaps then
    for key in pairs(config.keymaps) do
      if type(key) ~= "number" then
        table.insert(errors, "keymaps must be a list")
        break
      end
    end
    for index, item in ipairs(config.keymaps) do
      validate_keymap(errors, index, item)
    end
  end

  validate_plugin_specs(errors, config)
  validate_hooks(errors, config)

  if has_ai then
    expect(errors, "ai.sidekick", config.ai.sidekick, "table")
  end

  if has_mini then
    if type(config.mini.modules) ~= "table" then
      table.insert(errors, "mini.modules must be a list")
    else
      for _, module in ipairs(config.mini.modules) do
        if type(module) ~= "string" then
          table.insert(errors, "mini.modules entries must be strings")
          break
        end
        local name = module:gsub("^mini%.", "")
        if name == "" or not name:match(valid_mini_module) then
          table.insert(errors, "mini.modules entries must be mini module names like ai, surround, or mini.ai")
          break
        end
      end
    end
    expect(errors, "mini.opts", config.mini.opts, "table")
  end

  if has_extras then
    if type(config.extras.enabled) ~= "table" then
      table.insert(errors, "extras.enabled must be a list")
    else
      for _, extra in ipairs(config.extras.enabled) do
        if type(extra) ~= "string" then
          table.insert(errors, "extras.enabled entries must be strings")
          break
        end
      end
    end
  end

  if #errors > 0 then
    error("Blak config validation failed:\n- " .. table.concat(errors, "\n- "))
  end

  return config
end

return M
