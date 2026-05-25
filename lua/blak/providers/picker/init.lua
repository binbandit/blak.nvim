local M = {}

local providers = {
  fff = "blak.providers.picker.fff",
  snacks = "blak.providers.picker.snacks",
  telescope = "blak.providers.picker.telescope",
  fzf_lua = "blak.providers.picker.fzf_lua",
}

local project_kinds = {
  smart = true,
  files = true,
  grep = true,
}

local function with_project_cwd(kind, opts)
  opts = opts or {}
  if not project_kinds[kind] or opts.cwd then
    return opts
  end

  local copy = vim.tbl_extend("force", {}, opts)
  copy.cwd = require("blak.util").git_root()
  return copy
end

local function order(primary)
  local config = require("blak.config").get()
  primary = primary or config.picker.provider or "fff"
  local seen = {}
  local out = {}
  for _, name in ipairs({ primary, "snacks", "fff", "telescope", "fzf_lua" }) do
    if not seen[name] then
      seen[name] = true
      table.insert(out, name)
    end
  end
  return out
end

function M.pick(kind, opts)
  kind = kind or "files"
  if kind == "smart" then
    kind = "files"
  end
  opts = with_project_cwd(kind, opts)

  for _, name in ipairs(order(opts.provider)) do
    local module = providers[name]
    local ok, provider = pcall(require, module)
    if ok and provider[kind] then
      local ok_call, result = pcall(provider[kind], opts)
      if ok_call then
        return result
      end
    end
  end

  require("blak.util").warn("No picker could handle: " .. kind)
end

function M.smart(opts)
  return M.pick("files", opts)
end

return M
