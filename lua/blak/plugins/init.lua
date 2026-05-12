local M = {}

local modules = {
  "blak.plugins.ui",
  "blak.plugins.editor",
  "blak.plugins.picker",
  "blak.plugins.completion",
  "blak.plugins.lsp",
  "blak.plugins.formatting",
  "blak.plugins.git",
}

local function append(target, specs)
  for _, spec in ipairs(specs or {}) do
    table.insert(target, spec)
  end
end

function M.specs(config)
  local specs = {}
  for _, module in ipairs(modules) do
    append(specs, require(module)(config))
  end
  append(specs, config._extra_plugin_specs or {})
  return specs
end

return M
