local M = {}

local function path()
  return require("blak.util").join(vim.fn.stdpath("state"), "blak", "extras.json")
end

function M.read()
  local util = require("blak.util")
  local data = util.read_file(path())
  if not data or data == "" then
    return {}
  end
  local ok, decoded = pcall(vim.json.decode, data)
  if
    ok
    and type(decoded) == "table"
    and type(decoded.enabled) == "table"
    and vim.islist(decoded.enabled)
  then
    local valid = true
    for _, id in ipairs(decoded.enabled) do
      if type(id) ~= "string" or id == "" then
        valid = false
        break
      end
    end
    if valid then
      return util.unique(decoded.enabled)
    end
  end
  util.warn("Could not parse extras state; ignoring " .. path())
  return {}
end

function M.write(ids)
  local util = require("blak.util")
  util.write_file(path(), vim.json.encode({ enabled = require("blak.util").unique(ids) }))
end

return M
