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
    local ok = pcall(require, "fff")
    if ok then
      h.ok("fff.nvim is loadable")
    else
      h.warn("fff.nvim is not loadable yet. Run :Lazy sync, then restart.")
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
