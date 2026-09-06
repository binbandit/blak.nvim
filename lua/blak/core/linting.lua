local M = {}

local GROUP = "BlakLint"

-- nvim-lint reports failures asynchronously, so wrapping `try_lint` in pcall
-- catches nothing. Two failure modes reach the user instead:
--
--   1. A configured linter is not installed yet, so every lint event raises
--      "Error running <cmd>: ENOENT".
--   2. A linter writes plain text to stdout (eslint_d does this for config and
--      plugin resolution errors), so the JSON parser fails and nvim-lint pins a
--      synthetic "Could not parse linter output" diagnostic to line 1.
--
-- Both are handled here: missing linters are filtered out before they spawn,
-- and unparseable output is reported once instead of masquerading as a
-- diagnostic in the buffer.

---Resolve a linter's command, which nvim-lint allows to be a function.
---@param linter table
---@return string?
local function resolve_cmd(linter)
  local cmd = linter and linter.cmd
  if type(cmd) == "function" then
    local ok, resolved = pcall(cmd)
    cmd = ok and resolved or nil
  end
  if type(cmd) == "string" and cmd ~= "" then
    return cmd
  end
  return nil
end

---@param linter table
---@return boolean
function M.is_available(linter)
  local cmd = resolve_cmd(linter)
  if not cmd then
    return false
  end
  return require("blak.util").executable(cmd)
end

---Collapse linter output into a single line short enough for a notification.
---@param output string
---@return string
local function summarize(output)
  if type(output) ~= "string" then
    return "no output"
  end

  local limit = 240
  local lines = {}
  local length = 0

  -- Linter output can be arbitrarily large, so stop reading once there is
  -- enough text to fill the notification.
  for line in output:gmatch("[^\r\n]+") do
    local trimmed = vim.trim(line)
    if trimmed ~= "" then
      table.insert(lines, trimmed)
      length = length + #trimmed + 1
      if length > limit then
        break
      end
    end
  end

  if #lines == 0 then
    return "no output"
  end

  local summary = table.concat(lines, " ")
  if #summary > limit then
    return summary:sub(1, limit) .. "..."
  end
  return summary
end

local function warn_once(name, detail)
  local notify = vim.notify_once or vim.notify
  notify(name .. " failed: " .. detail, vim.log.levels.WARN)
end

---Wrap a parser so unparseable output never becomes a buffer diagnostic.
---@param name string
---@param parser function
---@return function
local function wrap_parser(name, parser)
  return function(output, bufnr, cwd)
    local ok, diagnostics = pcall(parser, output, bufnr, cwd)
    if not ok then
      warn_once(name, tostring(diagnostics))
      return {}
    end
    if type(diagnostics) ~= "table" then
      return {}
    end

    local kept = {}
    for _, diagnostic in ipairs(diagnostics) do
      local message = type(diagnostic) == "table" and diagnostic.message or nil
      -- This tracks nvim-lint's own wording for a failed JSON decode; if that
      -- string changes upstream the synthetic diagnostic comes back.
      if type(message) == "string" and message:find("Could not parse linter output", 1, true) then
        warn_once(name, summarize(output))
      else
        table.insert(kept, diagnostic)
      end
    end
    return kept
  end
end

---@param name string
---@param linter table
---@return table
local function harden(name, linter)
  if type(linter) ~= "table" or linter.blak_hardened or type(linter.parser) ~= "function" then
    return linter
  end

  local hardened = vim.tbl_extend("force", {}, linter)
  hardened.parser = wrap_parser(name, linter.parser)
  hardened.blak_hardened = true
  return hardened
end

-- Function-shaped linters cannot carry a `blak_hardened` flag, so wrappers are
-- tracked here instead. Weak keys let a replaced linter be collected.
local hardened_factories = setmetatable({}, { __mode = "k" })

---Replace each configured linter with a version that cannot pin parse failures
---to the buffer. nvim-lint resolves `lint.linters` lazily and allows a linter to
---be a function, so both shapes are handled. Safe to call repeatedly: config
---reloads must not stack wrappers.
---@param lint table
---@param linters_by_ft table<string, string[]>
local function harden_linters(lint, linters_by_ft)
  local seen = {}
  for _, names in pairs(linters_by_ft or {}) do
    for _, name in ipairs(names or {}) do
      if not seen[name] then
        seen[name] = true
        local ok, linter = pcall(function()
          return lint.linters[name]
        end)
        if ok and type(linter) == "function" and not hardened_factories[linter] then
          local factory = function()
            return harden(name, linter())
          end
          hardened_factories[factory] = true
          lint.linters[name] = factory
        elseif ok and type(linter) == "table" then
          lint.linters[name] = harden(name, linter)
        end
      end
    end
  end
end

---@param config table
function M.setup(config)
  local ok_lint, lint = pcall(require, "lint")
  if not ok_lint then
    return
  end

  local linters_by_ft = config.lint.linters_by_ft or {}
  lint.linters_by_ft = linters_by_ft
  harden_linters(lint, linters_by_ft)

  local group = vim.api.nvim_create_augroup(GROUP, { clear = true })
  local events = config.lint.events or {}
  if #events == 0 then
    return
  end

  vim.api.nvim_create_autocmd(events, {
    group = group,
    callback = function()
      -- `ignore_errors` covers spawn failures that slip past the filter, such as
      -- a linter removed between the check and the spawn.
      pcall(lint.try_lint, nil, {
        ignore_errors = true,
        filter = M.is_available,
      })
    end,
  })
end

---Linter names configured for any filetype, deduplicated and sorted.
---@param config table
---@return string[]
function M.linters(config)
  local seen = {}
  for _, names in pairs(config.lint.linters_by_ft or {}) do
    for _, name in ipairs(names or {}) do
      seen[name] = true
    end
  end

  local names = vim.tbl_keys(seen)
  table.sort(names)
  return names
end

return M
