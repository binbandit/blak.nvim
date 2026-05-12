local M = {}

local providers = {
  fff = "blak.providers.picker.fff",
  snacks = "blak.providers.picker.snacks",
  telescope = "blak.providers.picker.telescope",
  fzf_lua = "blak.providers.picker.fzf_lua",
}

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
  kind = kind or "smart"
  opts = opts or {}

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
  opts = opts or {}
  opts.cwd = opts.cwd or require("blak.util").git_root()
  return M.pick("files", opts)
end

return M
