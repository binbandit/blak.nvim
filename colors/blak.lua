local ok, theme = pcall(require, "blak.theme")
if ok then
  theme.load()
else
  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  vim.o.background = "dark"
  vim.g.colors_name = "blak"
  vim.api.nvim_set_hl(0, "Normal", { fg = "#f2f2f2", bg = "#000000" })
  vim.api.nvim_set_hl(0, "Comment", { fg = "#707070", italic = true })
  vim.api.nvim_set_hl(0, "Statement", { fg = "#ff7a18" })
  vim.api.nvim_set_hl(0, "Special", { fg = "#ff7a18" })
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#ff3d1f" })
  vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#ff7a18" })
end
