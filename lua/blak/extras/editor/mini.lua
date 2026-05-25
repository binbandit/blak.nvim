local function mini_module_name(name)
  name = name:gsub("^mini%.", "")
  return name
end

local function mini_module_opts(config, name)
  local opts = vim.tbl_get(config, "mini", "opts") or {}
  return opts[name] or opts["mini." .. name] or {}
end

local function mini_module_specs(config)
  local specs = {}
  local seen = {}
  local skipped_modules = { icons = true, pairs = true }
  for _, raw_name in ipairs(vim.tbl_get(config, "mini", "modules") or {}) do
    local name = mini_module_name(raw_name)
    if not seen[name] and not skipped_modules[name] then
      seen[name] = true
      local require_name = "mini." .. name
      table.insert(specs, {
        "nvim-mini/mini." .. name,
        version = false,
        event = "VeryLazy",
        opts = mini_module_opts(config, name),
        config = function(_, opts)
          require(require_name).setup(opts)
        end,
      })
    end
  end
  return specs
end

return {
  id = "editor.mini",
  label = "Mini.nvim modules",
  description = "Install and set up configured nvim-mini modules",
  plugins = mini_module_specs,
}
