local M = {}

---Path of a verified fff download that was never installed.
---
---fff.nvim skips the final rename when the old library is still loaded, leaving
---the new one at `<binary>.tmp` for the next session to promote. Nothing on its
---require path promotes it, so the state survives restarts.
---@return string?
local function fff_stranded_download()
  local ok, download = pcall(require, "fff.download")
  if not ok or type(download.get_binary_path) ~= "function" then
    return nil
  end

  local ok_path, path = pcall(download.get_binary_path)
  if not ok_path or type(path) ~= "string" then
    return nil
  end

  local tmp = path .. ".tmp"
  local stat = vim.uv.fs_stat(tmp)
  if stat and stat.type == "file" then
    return tmp
  end
  return nil
end

---Whether fff.nvim can actually run.
---
---`require("fff")` resolves to `fff.main`, which defers the Rust backend into
---function bodies, so it succeeds even with no native library on disk. Probe the
---backend directly instead.
---@return "ok"|"missing-plugin"|"stranded-download"|"missing-binary"
function M.fff_status()
  if not pcall(require, "fff") then
    return "missing-plugin"
  end
  if pcall(require, "fff.fuzzy") then
    return "ok"
  end
  if fff_stranded_download() then
    return "stranded-download"
  end
  return "missing-binary"
end

---Plugins an extra declares that lazy.nvim has not installed.
---@return string[]
local function missing_plugins(extra, config)
  local specs = type(extra.plugins) == "function" and extra.plugins(config) or extra.plugins
  local ok, plugins = pcall(function()
    return require("lazy.core.config").plugins
  end)
  local missing = {}
  for _, spec in ipairs(ok and specs or {}) do
    local name = spec.name or (type(spec[1]) == "string" and spec[1]:match("[^/]+$"))
    local plugin = name and plugins[name]
    if plugin and not plugin._.installed then
      table.insert(missing, name)
    end
  end
  return missing
end

local BUILD_HINT = ':lua require("fff.download").download_or_build_binary()'

function M.check()
  local h = vim.health
  local config = require("blak.config").get()
  local util = require("blak.util")

  h.start("Blak")

  if vim.fn.has("nvim-0.12") == 1 then
    h.ok("Neovim >= 0.12")
  else
    h.error("Blak targets Neovim 0.12+. Upgrade Neovim for native LSP and current plugin APIs.")
  end

  if vim.o.termguicolors then
    h.ok("termguicolors is enabled")
  else
    h.error("termguicolors is required for the Blak splash and theme")
  end

  for _, binary in ipairs({ "git", "rg", "fd", "tree-sitter" }) do
    if util.executable(binary) then
      h.ok(binary .. " found")
    else
      if binary == "tree-sitter" then
        h.warn(
          "tree-sitter not found. Run :BlakToolsInstall, then :BlakTreesitterInstall to install parsers."
        )
      else
        h.warn(binary .. " not found. Some picker/search features will be degraded.")
      end
    end
  end

  if config.picker.provider == "fff" then
    local status = M.fff_status()
    if status == "ok" then
      h.ok("fff.nvim is loadable")
    elseif status == "missing-plugin" then
      h.warn("fff.nvim is not loadable yet. Run :BlakExtras sync, then :restart.")
    elseif status == "stranded-download" then
      h.warn(
        "fff.nvim downloaded its native library but could not install it, so the picker "
          .. "will not start. Run "
          .. BUILD_HINT
          .. ", then :restart. Stranded download: "
          .. tostring(fff_stranded_download())
      )
    else
      h.warn(
        "fff.nvim is installed but its native library is missing, so the picker will not "
          .. "start. Run "
          .. BUILD_HINT
          .. ", then :restart."
      )
    end
  end

  h.start("Enabled extras")
  local extras = require("blak.extras")
  local enabled = extras.enabled(config)
  if #enabled == 0 then
    h.info("No extras enabled")
  else
    for _, id in ipairs(enabled) do
      if extras.is_known(id) then
        local missing = missing_plugins(extras.get(id), config)
        if #missing == 0 then
          h.ok(id)
        else
          h.warn(
            id
              .. " needs plugins that are not installed: "
              .. table.concat(missing, ", ")
              .. ". Run :BlakExtras sync, then :restart."
          )
        end
      else
        h.warn(
          (extras.removed(id) or ("Unknown extra: " .. id .. "."))
            .. " Run :BlakExtras disable "
            .. id
            .. " to remove stale state."
        )
      end
    end
  end

  h.start("Linters")
  local linting = require("blak.core.linting")
  local linter_names = linting.linters(config)
  if #linter_names == 0 then
    h.info("No linters configured")
  else
    local ok_lint, lint = pcall(require, "lint")
    for _, name in ipairs(linter_names) do
      local resolved_ok, linter = pcall(function()
        local definition = ok_lint and lint.linters[name] or nil
        return type(definition) == "function" and definition() or definition
      end)
      linter = resolved_ok and linter or nil
      if type(linter) ~= "table" then
        h.warn(name .. " is configured but nvim-lint has no such linter")
      elseif linting.is_available(linter) then
        h.ok(name .. " found")
      else
        h.warn(name .. " not found; it is skipped until installed. Run :BlakToolsInstall.")
      end
    end
  end

  if config.lsp.servers.ts_ls then
    h.start("TypeScript")
    local path = require("blak.providers.typescript").mason_path()
    if path then
      h.ok("Mason TypeScript fallback: " .. path)
    else
      h.warn(
        "Mason's TypeScript fallback is missing or has no tsserver.js. Run :BlakToolsInstall, "
          .. "wait for installation, then :restart. ts_ls requires TypeScript with tsserver.js (before TS 7); "
          .. "a compatible workspace SDK or explicit init_options.tsserver.path can also supply it."
      )
    end
  end

  h.start("Mason tools")
  local ok_registry, registry = pcall(require, "mason-registry")
  for _, pkg in ipairs(require("blak.core.tools").list(config)) do
    local ok_pkg, installed = pcall(function()
      return registry.get_package(pkg):is_installed()
    end)
    if not ok_registry then
      h.info(pkg)
    elseif not ok_pkg then
      h.warn(pkg .. " is not a Mason package")
    elseif installed then
      h.ok(pkg)
    else
      h.warn(pkg .. " is not installed. Run :BlakToolsInstall; see :MasonLog if it keeps failing.")
    end
  end
end

return M
