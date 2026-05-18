local M = {}

local valid_channels = { stable = true, edge = true, nightly = true }
local valid_pickers = { fff = true, snacks = true, telescope = true, fzf_lua = true }
local valid_explorers = { oil = true, snacks = true }

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

function M.validate(config)
  local errors = {}

  expect(errors, "leader", config.leader, "string")
  expect(errors, "localleader", config.localleader, "string")
  local has_package = expect(errors, "package", config.package, "table")
  expect(errors, "ui", config.ui, "table")
  local has_picker = expect(errors, "picker", config.picker, "table")
  local has_explorer = expect(errors, "explorer", config.explorer, "table")
  expect(errors, "lsp", config.lsp, "table")
  local has_extras = expect(errors, "extras", config.extras, "table")

  if has_package and not valid_channels[config.package.channel] then
    table.insert(errors, "package.channel must be stable, edge, or nightly")
  end

  if has_picker and not valid_pickers[config.picker.provider] then
    table.insert(errors, "picker.provider must be fff, snacks, telescope, or fzf_lua")
  end

  if has_explorer and not valid_explorers[config.explorer.provider] then
    table.insert(errors, "explorer.provider must be oil or snacks")
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
