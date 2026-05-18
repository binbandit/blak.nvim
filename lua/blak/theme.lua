local M = {}

local function is_tokyonight_scheme(name)
  return type(name) == "string" and name:match("^tokyonight") ~= nil
end

local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "SignColumn",
  "FoldColumn",
  "EndOfBuffer",
  "MsgArea",
  "StatusLine",
  "StatusLineNC",
  "TabLine",
  "TabLineFill",
  "WinBar",
  "WinBarNC",
}

local function theme_config(config)
  return ((config or {}).ui or {}).theme
end

local function wants_transparency(config)
  local theme = theme_config(config)
  return vim.tbl_get(config or {}, "ui", "transparent") == true
    or (type(theme) == "table" and theme.transparent == true)
end

function M.theme_opts(config)
  local theme = theme_config(config)
  local opts = type(theme) == "table" and vim.deepcopy(theme) or {}
  if wants_transparency(config) and opts.transparent == nil then
    opts.transparent = true
  end
  return opts
end

function M.tokyonight_opts(config)
  return M.theme_opts(config)
end

function M.setup_tokyonight(config)
  local ok, tokyonight = pcall(require, "tokyonight")
  if not ok then
    return false
  end
  tokyonight.setup(M.theme_opts(config or require("blak.config").get()))
  return true
end

local function add_candidate(candidates, seen, value)
  if type(value) ~= "string" or value == "" or seen[value] then
    return
  end
  seen[value] = true
  table.insert(candidates, value)
end

function M.setup_module_candidates(config, name)
  local candidates = {}
  local seen = {}

  add_candidate(candidates, seen, name)
  if type(name) == "string" then
    add_candidate(candidates, seen, name:match("^(.*)%-.+$"))
  end

  return candidates
end

function M.setup_colorscheme(config, name)
  local opts = M.theme_opts(config)
  if vim.tbl_isempty(opts) then
    return false
  end

  local util = require("blak.util")
  for _, module in ipairs(M.setup_module_candidates(config, name)) do
    local ok, theme = pcall(require, module)
    if ok then
      if type(theme) == "table" and type(theme.setup) == "function" then
        local setup_ok, err = pcall(theme.setup, opts)
        if not setup_ok then
          util.warn("Could not configure theme module " .. module .. ": " .. tostring(err))
        end
        return setup_ok
      end
    elseif not util.is_module_not_found(ok and nil or theme, module) then
      util.warn("Could not load theme module " .. module .. ": " .. tostring(theme))
      return false
    end
  end

  return false
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
  if not M.setup_colorscheme(config, "tokyonight-night") then
    M.setup_tokyonight(config)
  end
  return pcall(vim.cmd.colorscheme, "tokyonight-night")
end

function M.apply_transparency(config)
  if not wants_transparency(config) then
    return
  end

  for _, group in ipairs(transparent_groups) do
    local ok, highlight = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if ok and not vim.tbl_isempty(highlight) then
      highlight.bg = nil
      highlight.ctermbg = nil
      vim.api.nvim_set_hl(0, group, highlight)
    end
  end
end

local function setup_transparency_autocmd(config)
  local group = vim.api.nvim_create_augroup("BlakThemeTransparency", { clear = true })
  if not wants_transparency(config) then
    return
  end

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      require("blak.theme").apply_transparency(require("blak.config").get())
    end,
  })
end

local function finish_load(config)
  setup_transparency_autocmd(config)
  M.apply_transparency(config)
end

function M.load(config)
  config = config or require("blak.config").get()
  local name = ((config or {}).ui or {}).colorscheme

  if name ~= nil and name ~= "" then
    if not M.setup_colorscheme(config, name) and is_tokyonight_scheme(name) then
      M.setup_tokyonight(config)
    end
    local ok = pcall(vim.cmd.colorscheme, name)
    if ok then
      finish_load(config)
      return
    end
    require("blak.util").warn(
      "Could not load colorscheme " .. tostring(name) .. "; falling back to TokyoNight."
    )
  end

  if not load_tokyonight(config) then
    fallback()
  end
  finish_load(config)
end

return M
