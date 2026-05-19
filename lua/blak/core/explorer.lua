local M = {}

local function provider(config)
  config = config or require("blak.config").get()
  return (config.explorer and config.explorer.provider) or "oil"
end

local function snacks_explorer_pickers(snacks)
  if not vim.tbl_get(snacks, "picker", "get") then
    return {}
  end

  local ok, pickers = pcall(snacks.picker.get, { source = "explorer" })
  if ok and type(pickers) == "table" then
    return pickers
  end
  return {}
end

local function close_snacks_explorer(snacks)
  local picker = snacks_explorer_pickers(snacks)[1]
  if not picker or type(picker.close) ~= "function" then
    return false
  end

  pcall(picker.close, picker)
  return true
end

function M.open(config)
  local util = require("blak.util")
  local name = provider(config)

  if name == "snacks" then
    local snacks = util.load_plugin("snacks.nvim", "snacks")
    if snacks and snacks.explorer then
      if close_snacks_explorer(snacks) then
        return nil
      end
      return snacks.explorer({ cwd = util.git_root() })
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
