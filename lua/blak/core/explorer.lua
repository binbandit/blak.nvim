local M = {}

local function provider(config)
  config = config or require("blak.config").get()
  return (config.explorer and config.explorer.provider) or "oil"
end

function M.open(config)
  local util = require("blak.util")
  local name = provider(config)

  if name == "snacks" then
    local snacks = util.load_plugin("snacks.nvim", "snacks")
    if snacks and snacks.explorer then
      return snacks.explorer()
    end
    return nil
  end

  local oil = util.load_plugin("oil.nvim", "oil")
  if oil then
    return oil.open()
  end
  return nil
end

function M.label(config)
  return provider(config) == "snacks" and "Snacks explorer" or "Explorer"
end

return M
