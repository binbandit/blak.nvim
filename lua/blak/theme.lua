local M = {}

local palette = {
  bg = "#000000",
  bg_alt = "#050505",
  surface = "#0b0b0b",
  surface2 = "#121212",
  border = "#242424",
  fg = "#f2f2f2",
  fg_dim = "#c8c8c8",
  muted = "#707070",
  faint = "#4a4a4a",
  orange = "#ff7a18",
  orange_soft = "#ff9d2e",
  red_orange = "#ff3d1f",
}

M.palette = palette

local function is_blak_scheme(name)
  return name == nil or name == "" or name == "blak"
end

function M.tokyonight_opts(config)
  local theme = ((config or {}).ui or {}).theme or {}

  return {
    style = theme.style or "night",
    light_style = "day",
    transparent = theme.transparent == true,
    terminal_colors = true,
    dim_inactive = theme.dim_inactive == true,
    lualine_bold = false,
    cache = true,
    styles = {
      comments = { italic = true },
      keywords = {},
      functions = {},
      variables = {},
      sidebars = "dark",
      floats = "dark",
    },
    plugins = {
      auto = true,
      all = false,
    },
    on_colors = function(colors)
      colors.bg = palette.bg
      colors.bg_dark = palette.bg
      colors.bg_float = palette.surface
      colors.bg_highlight = palette.surface2
      colors.bg_popup = palette.surface
      colors.bg_search = palette.orange
      colors.bg_sidebar = palette.bg
      colors.bg_statusline = palette.bg_alt
      colors.border = palette.border

      colors.fg = palette.fg
      colors.fg_dark = palette.fg_dim
      colors.fg_float = palette.fg
      colors.fg_gutter = palette.faint
      colors.fg_sidebar = palette.fg_dim
      colors.comment = palette.muted
      colors.dark3 = palette.faint
      colors.dark5 = palette.muted
      colors.terminal_black = palette.bg_alt
      colors.black = palette.bg_alt

      -- Keep the palette intentionally severe: monochrome first, black-hole heat second.
      -- TokyoNight still derives hundreds of plugin groups from these semantic colors.
      colors.blue = palette.fg_dim
      colors.blue0 = palette.fg
      colors.blue1 = palette.fg
      colors.blue2 = palette.fg_dim
      colors.blue5 = "#a8a8a8"
      colors.blue6 = "#9a9a9a"
      colors.blue7 = palette.muted
      colors.cyan = "#d6d6d6"
      colors.green = "#dddddd"
      colors.green1 = palette.fg
      colors.green2 = palette.fg_dim
      colors.magenta = palette.orange
      colors.magenta2 = palette.red_orange
      colors.orange = palette.orange
      colors.purple = palette.orange_soft
      colors.red = palette.red_orange
      colors.red1 = "#ff6347"
      colors.teal = "#dedede"
      colors.yellow = palette.orange_soft

      colors.error = palette.red_orange
      colors.warning = palette.orange
      colors.info = palette.fg_dim
      colors.hint = palette.fg

      colors.git = vim.tbl_deep_extend("force", colors.git or {}, {
        add = palette.fg_dim,
        change = palette.orange,
        delete = palette.red_orange,
        conflict = palette.orange_soft,
        ignore = palette.muted,
      })
    end,
    on_highlights = function(hl, c)
      local transparent = theme.transparent == true
      local normal_bg = transparent and "NONE" or palette.bg
      local float_bg = transparent and "NONE" or palette.surface

      hl.Normal = { fg = palette.fg, bg = normal_bg }
      hl.NormalNC = { fg = palette.fg_dim, bg = normal_bg }
      hl.NormalFloat = { fg = palette.fg, bg = float_bg }
      hl.FloatBorder = { fg = palette.border, bg = float_bg }
      hl.FloatTitle = { fg = palette.orange, bg = float_bg, bold = true }
      hl.WinSeparator = { fg = palette.border }
      hl.CursorLine = { bg = transparent and "NONE" or palette.bg_alt }
      hl.CursorLineNr = { fg = palette.fg, bold = true }
      hl.LineNr = { fg = palette.faint }
      hl.SignColumn = { bg = normal_bg }
      hl.Visual = { bg = palette.surface2 }
      hl.Search = { fg = palette.bg, bg = palette.orange_soft }
      hl.IncSearch = { fg = palette.bg, bg = palette.orange }
      hl.MatchParen = { fg = palette.orange, bg = palette.surface2, bold = true }
      hl.Pmenu = { fg = palette.fg_dim, bg = palette.surface }
      hl.PmenuSel = { fg = palette.bg, bg = palette.fg }
      hl.PmenuMatch = { fg = palette.orange, bg = palette.surface, bold = true }
      hl.PmenuMatchSel = { fg = palette.red_orange, bg = palette.fg, bold = true }

      hl.BlakAccent = { fg = palette.orange, bold = true }
      hl.BlakHot = { fg = palette.red_orange, bold = true }
      hl.BlakMuted = { fg = palette.muted }

      -- Blak-owned surfaces and brand groups. Broad plugin coverage remains TokyoNight's job.
      hl.SnacksDashboardHeader = { fg = palette.orange, bold = true }
      hl.SnacksDashboardTitle = { fg = palette.fg, bold = true }
      hl.SnacksDashboardIcon = { fg = palette.red_orange }
      hl.SnacksDashboardKey = { fg = palette.orange, bold = true }
      hl.SnacksDashboardDesc = { fg = palette.fg_dim }
      hl.SnacksDashboardFooter = { fg = palette.muted }
      hl.SnacksNotifierBorderInfo = { fg = palette.border }
      hl.SnacksNotifierTitleInfo = { fg = palette.orange }

      hl.BlinkCmpLabelMatch = { fg = palette.orange, bold = true }
      hl.BlinkCmpMenu = { fg = palette.fg_dim, bg = palette.surface }
      hl.BlinkCmpMenuBorder = { fg = palette.border, bg = palette.surface }
      hl.BlinkCmpDoc = { fg = palette.fg_dim, bg = palette.surface }
      hl.BlinkCmpDocBorder = { fg = palette.border, bg = palette.surface }

      hl.OilDir = { fg = palette.fg, bold = true }
      hl.OilFile = { fg = palette.fg_dim }
      hl.OilCreate = { fg = palette.orange }
      hl.OilDelete = { fg = palette.red_orange }
      hl.OilMove = { fg = palette.orange_soft }

      hl.GitSignsAdd = { fg = palette.fg_dim }
      hl.GitSignsChange = { fg = palette.orange }
      hl.GitSignsDelete = { fg = palette.red_orange }

      if type(theme.on_highlights) == "function" then
        theme.on_highlights(hl, c, palette)
      end
    end,
  }
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
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.o.background = "dark"
  vim.g.colors_name = "blak"

  local function hl(group, spec)
    vim.api.nvim_set_hl(0, group, spec)
  end

  hl("Normal", { fg = palette.fg, bg = palette.bg })
  hl("NormalFloat", { fg = palette.fg, bg = palette.surface })
  hl("FloatBorder", { fg = palette.border, bg = palette.surface })
  hl("CursorLine", { bg = palette.bg_alt })
  hl("CursorLineNr", { fg = palette.fg, bold = true })
  hl("LineNr", { fg = palette.faint })
  hl("SignColumn", { bg = palette.bg })
  hl("WinSeparator", { fg = palette.border })
  hl("Visual", { bg = palette.surface2 })
  hl("Search", { fg = palette.bg, bg = palette.orange_soft })
  hl("IncSearch", { fg = palette.bg, bg = palette.orange })
  hl("Pmenu", { fg = palette.fg_dim, bg = palette.surface })
  hl("PmenuSel", { fg = palette.bg, bg = palette.fg })
  hl("Comment", { fg = palette.muted, italic = true })
  hl("Constant", { fg = palette.fg_dim })
  hl("String", { fg = palette.fg_dim })
  hl("Identifier", { fg = palette.fg })
  hl("Function", { fg = palette.fg, bold = true })
  hl("Statement", { fg = palette.orange })
  hl("PreProc", { fg = palette.orange_soft })
  hl("Type", { fg = palette.fg_dim })
  hl("Special", { fg = palette.orange })
  hl("DiagnosticError", { fg = palette.red_orange })
  hl("DiagnosticWarn", { fg = palette.orange })
  hl("DiagnosticInfo", { fg = palette.fg_dim })
  hl("DiagnosticHint", { fg = palette.fg })
  hl("BlakAccent", { fg = palette.orange, bold = true })
  hl("BlakHot", { fg = palette.red_orange, bold = true })
  hl("BlakMuted", { fg = palette.muted })
end

function M.load(config)
  config = config or require("blak.config").get()
  local name = ((config or {}).ui or {}).colorscheme

  if not is_blak_scheme(name) then
    local ok = pcall(vim.cmd.colorscheme, name)
    if not ok then
      require("blak.util").warn(
        "Could not load colorscheme " .. tostring(name) .. "; falling back to Blak."
      )
      fallback()
    end
    return
  end

  if not M.setup_tokyonight(config) then
    fallback()
    return
  end

  local ok = pcall(vim.cmd.colorscheme, "tokyonight-night")
  if not ok then
    fallback()
    return
  end

  -- Preserve the public colorscheme name while using TokyoNight's generated groups.
  vim.g.colors_name = "blak"
end

return M
