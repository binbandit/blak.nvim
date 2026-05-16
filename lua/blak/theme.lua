local M = {}

local function is_tokyonight_scheme(name)
  return type(name) == "string" and name:match("^tokyonight") ~= nil
end

function M.tokyonight_opts(config)
  local theme = ((config or {}).ui or {}).theme
  return type(theme) == "table" and vim.deepcopy(theme) or {}
end

function M.setup_tokyonight(config)
  local ok, tokyonight = pcall(require, "tokyonight")
  if not ok then
    return false
  end
  tokyonight.setup(M.tokyonight_opts(config or require("blak.config").get()))
  return true
end

local function fallback()
  vim.o.background = "dark"
  if not pcall(vim.cmd.colorscheme, "habamax") then
    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") == 1 then
      vim.cmd("syntax reset")
    end
  end
end

local function load_tokyonight(config)
  if not M.setup_tokyonight(config) then
    return false
  end
  return pcall(vim.cmd.colorscheme, "tokyonight-night")
end

function M.load(config)
  config = config or require("blak.config").get()
  local name = ((config or {}).ui or {}).colorscheme

  if name ~= nil and name ~= "" then
    if is_tokyonight_scheme(name) then
      M.setup_tokyonight(config)
    end
    local ok = pcall(vim.cmd.colorscheme, name)
    if ok then
      return
    end
    require("blak.util").warn(
      "Could not load colorscheme " .. tostring(name) .. "; falling back to TokyoNight."
    )
  end

  if not load_tokyonight(config) then
    fallback()
  end
end

return M
