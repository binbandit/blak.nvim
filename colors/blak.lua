vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "blak"

local p = {
  bg = "#000000",
  bg2 = "#090909",
  bg3 = "#111111",
  fg = "#d8d8d8",
  dim = "#7a7a7a",
  muted = "#555555",
  accent = "#f1f1f1",
  red = "#ff6b6b",
  orange = "#f5a97f",
  yellow = "#eed49f",
  green = "#a6da95",
  cyan = "#8bd5ca",
  blue = "#8aadf4",
  purple = "#c6a0f6",
}

local function hl(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

hl("Normal", { fg = p.fg, bg = p.bg })
hl("NormalFloat", { fg = p.fg, bg = p.bg2 })
hl("FloatBorder", { fg = p.muted, bg = p.bg2 })
hl("CursorLine", { bg = p.bg2 })
hl("CursorLineNr", { fg = p.accent, bold = true })
hl("LineNr", { fg = p.muted })
hl("SignColumn", { bg = p.bg })
hl("StatusLine", { fg = p.fg, bg = p.bg3 })
hl("StatusLineNC", { fg = p.muted, bg = p.bg2 })
hl("WinSeparator", { fg = p.bg3 })
hl("Visual", { bg = "#252525" })
hl("Search", { fg = p.bg, bg = p.yellow })
hl("IncSearch", { fg = p.bg, bg = p.orange })
hl("Pmenu", { fg = p.fg, bg = p.bg2 })
hl("PmenuSel", { fg = p.bg, bg = p.accent })
hl("DiagnosticError", { fg = p.red })
hl("DiagnosticWarn", { fg = p.yellow })
hl("DiagnosticInfo", { fg = p.blue })
hl("DiagnosticHint", { fg = p.cyan })
hl("Comment", { fg = p.dim, italic = true })
hl("Constant", { fg = p.purple })
hl("String", { fg = p.green })
hl("Identifier", { fg = p.fg })
hl("Function", { fg = p.accent, bold = true })
hl("Statement", { fg = p.blue })
hl("PreProc", { fg = p.purple })
hl("Type", { fg = p.cyan })
hl("Special", { fg = p.orange })
hl("Error", { fg = p.red })
hl("Todo", { fg = p.bg, bg = p.yellow, bold = true })
hl("BlakAccent", { fg = p.accent, bold = true })
