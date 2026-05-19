local M = {}

local function package_list(config)
  return require("blak.util").unique(config.mason.ensure_installed or {})
end

function M.ensure(config, opts)
  opts = opts or {}
  local util = require("blak.util")
  local packages = package_list(config)
  if #packages == 0 then
    return
  end

  local registry = util.load_plugin("mason.nvim", "mason-registry")
  if not registry then
    util.warn("Mason registry is not available yet. Run :Lazy sync, restart, then retry :BlakToolsInstall.")
    return
  end

  local function install_missing()
    for _, name in ipairs(packages) do
      local ok_pkg, pkg = pcall(registry.get_package, name)
      if not ok_pkg then
        util.warn("Mason package not found: " .. name)
      elseif not pkg:is_installed() then
        util.notify("Installing Mason package: " .. name)
        local ok_install, err = pcall(function()
          pkg:install()
        end)
        if not ok_install then
          util.warn("Could not install " .. name .. ": " .. tostring(err))
        end
      elseif opts.force then
        util.notify("Already installed: " .. name)
      end
    end
  end

  if registry.refresh then
    registry.refresh(install_missing)
  else
    install_missing()
  end
end

function M.list(config)
  return package_list(config)
end

return M
