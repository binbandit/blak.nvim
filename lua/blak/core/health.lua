local M = {}

local function health_api()
  local h = vim.health or require("health")
  return {
    start = h.start or h.report_start,
    ok = h.ok or h.report_ok,
    warn = h.warn or h.report_warn,
    error = h.error or h.report_error,
    info = h.info or h.report_info,
  }
end

---Path of a verified fff download that was never installed.
---
---fff.nvim skips the final rename when the old library is still loaded, leaving
---the new one at `<binary>.tmp` for the next session to promote. Nothing on its
---require path promotes it, so the state survives restarts.
---@return string?
local function fff_stranded_download()
  local uv = vim.uv or vim.loop
  local ok, download = pcall(require, "fff.download")
  if not ok or type(download.get_binary_path) ~= "function" then
    return nil
  end

  local ok_path, path = pcall(download.get_binary_path)
  if not ok_path or type(path) ~= "string" then
    return nil
  end

  local tmp = path .. ".tmp"
  local stat = uv.fs_stat(tmp)
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

local BUILD_HINT = ':lua require("fff.download").download_or_build_binary()'

function M.check()
  local h = health_api()
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
        h.warn("tree-sitter not found. Run :BlakToolsInstall, then :BlakTreesitterInstall to install parsers.")
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
      h.warn("fff.nvim is not loadable yet. Run :Lazy sync, then restart.")
    elseif status == "stranded-download" then
      h.warn(
        "fff.nvim downloaded its native library but could not install it, so the picker "
          .. "will not start. Run "
          .. BUILD_HINT
          .. ", then restart. Stranded download: "
          .. tostring(fff_stranded_download())
      )
    else
      h.warn(
        "fff.nvim is installed but its native library is missing, so the picker will not "
          .. "start. Run "
          .. BUILD_HINT
          .. ", then restart."
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
        h.ok(id)
      else
        h.warn("Unknown extra: " .. id .. ". Run :BlakExtras disable " .. id .. " to remove stale state.")
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
      local linter = ok_lint and lint.linters[name] or nil
      if type(linter) == "function" then
        local resolved_ok, resolved = pcall(linter)
        linter = resolved_ok and resolved or nil
      end
      if type(linter) ~= "table" then
        h.warn(name .. " is configured but nvim-lint has no such linter")
      elseif linting.is_available(linter) then
        h.ok(name .. " found")
      else
        h.warn(name .. " not found; it is skipped until installed. Run :BlakToolsInstall.")
      end
    end
  end

  h.start("Mason tools")
  for _, pkg in ipairs(require("blak.core.tools").list(config)) do
    h.info(pkg)
  end
end

return M
